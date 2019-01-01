reduceData <- function(data, keyColumnNames) {
  library(lubridate)
  colnamesOfData <- colnames(data)
  valueColumnNames <- setdiff(colnamesOfData, keyColumnNames)
  stringWhichReplacesData <- ''
  lapply(1:(length(keyColumnNames) - 1), function(cardinalityOfSubsetOfKeyColumnNames) {
    subsettedKeyColumnNames <-
      combn(x = keyColumnNames, m = cardinalityOfSubsetOfKeyColumnNames)
    apply(subsettedKeyColumnNames, 2, function(x) {
      keyColumnNamesToTestReducability <- setdiff(keyColumnNames, x)
      groupVector <- c(x, valueColumnNames)
      data <<-
        data %>% inner_join(data %>% group_by(!!!syms(groupVector)) %>% summarise(cardinalityOfGroupVector =
                                                                                    n()),
                            by = groupVector) %>% inner_join(data %>% group_by(!!!syms(x)) %>% summarise(cardinalityOfKeyGroups = n()),
                                                             by = x)
      if (all(rowSums((data %>% select(x)) == stringWhichReplacesData) !=
          length(x))) {
        lapply(keyColumnNamesToTestReducability, function(keyColumnNameToTestReducability) {
          data <<-
            data %>% mutate(
              !!keyColumnNameToTestReducability := ifelse(
                data$cardinalityOfGroupVector == cardinalityOfKeyGroups,
                stringWhichReplacesData,
                data[[keyColumnNameToTestReducability]]
              )
            )
        })
      }
      data <<- data %>% distinct() %>% select(colnamesOfData)
    })
  })
  Filter(function(x)
    ! all(x == stringWhichReplacesData), data)
}
