# Example 1:
## A an error from functions on nested data.
library(purrr)
library(tidyverse)

mtcars

mtc <- mtcars

set.seed(1111)
rand_na <- function(vec) {
  index_na  <- rdunif(15, a = 1, b = length(vec))
  vec[index_na] <- NA
  vec
}

mtc$cyl <- rand_na(mtcars$cyl)

mtc %>%
  group_by(carb) %>%
  nest() %>%
  mutate(model = map(data, ~lm(mpg ~ cyl + hp + wt, data = .x)))

## What to do? We're one level of abstraction away from that error, we don't
## know which models failed.
##
## We could rewrite the code maybe wrap the lm call
## and insert some print statements.
## We could do safe_lm <- purrr::safely(lm)
## which would tell us where failures occurred but not why.
##
## Both of these options have the undesirable property that we have to alter the
## code we are trying to debug. We should be careful doing this as it's possible
## - particularly within the heat of the debugging moment - to introduce
## additional mistakes that will confound us and slow down the process.

## A simple but effective approach is to use recover:
options(error = recover)

## Enter a frame number, or 0 to exit

##  1: mtcars_test %>% group_by(carb) %>% nest() %>% mutate(model = map(data, ~lm(
##  2: withVisible(eval(quote(`_fseq`(`_lhs`)), env, env))
##  3: eval(quote(`_fseq`(`_lhs`)), env, env)
##  4: eval(quote(`_fseq`(`_lhs`)), env, env)
##  5: `_fseq`(`_lhs`)
##  6: freduce(value, `_function_list`)
##  7: withVisible(function_list[[k]](value))
##  8: function_list[[k]](value)
##  9: mutate(., model = map(data, ~lm(mpg ~ cyl + hp + wt, data = .x)))
## 10: mutate.tbl_df(., model = map(data, ~lm(mpg ~ cyl + hp + wt, data = .x)))
## 11: mutate_impl(.data, dots, caller_env())
## 12: map(data, ~lm(mpg ~ cyl + hp + wt, data = .x))
## 13: .f(.x[[i]], ...)
## 14: lm(mpg ~ cyl + hp + wt, data = .x)
## 15: lm.fit(x, y, offset = offset, singula.ok = singular.ok, ...)

mtcars_test %>%
  dplyr::filter(mpg == 15, is.na(cyl))

## But this is a bit tricky! We're inside the namespace of lm, which is stats.
## Inside here stats::filter takes precedence over dplyr::filter.
