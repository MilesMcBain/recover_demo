# Example 1:
## A an error from functions on nested data.
library(tidyverse)

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
  mutate(model = map(data, ~lm(mpg ~ cyl + hp + wt,
                               data = .x)))
