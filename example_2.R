## Example 2: An error during cross validation
library(tidyverse)
library(broom)
library(rsample)

mtc_f <-
  mtcars %>%
  mutate(carb = as.factor(as.character(carb)))

set.seed(30)
mtc_f_splits <- rsample::initial_split(mtc_f)

training(mtc_f_splits) %>%
  group_by(cyl) %>%
  nest() %>%
  mutate(model = map(data, ~lm(mpg ~ wt + carb,
                               data = .x))
         ) %>%
  mutate(output = map(model,
                      ~augment(.x,
                               newdata = testing(mtc_f_splits))))
