context("reduceData")

test_that("reducing a simple tibble works",{
  dt <- tibble(k1 = c("A","A","B","B"),k2 = c("c","e","c","e"),v1 = c(2,2,2,2))

  expect_equal(dt %>% reduceData(c("k1","k2")) %>% pull(v1),c(2,2))
})

test_that("if a column is independent from another column reducing the data works",{
  dt2 <- tibble(k1 = c("A","A","B","B"),k2 = c("c","e","c","e"),v1 = c(2,2,3,2))

  expect_equal(dt2 %>% reduceData(c("k1","k2")) %>% filter(k1 == "A") %>% nrow(),1)
  expect_equal(dt2 %>% reduceData(c("k1","k2")) %>% filter(k1 == "B") %>% nrow(),2)
})
