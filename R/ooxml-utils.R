ooxml_rotation_alignments <- function(rotation, align, valign) {
  halign_out <- align
  valign_out <- valign

  left_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "left"
  center_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "center"
  right_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "right"
  left_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "left"
  center_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "center"
  right_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "right"
  left_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "left"
  center_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "center"
  right_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "right"

  # left-top to right-top
  halign_out[left_top] <- "right"
  valign_out[left_top] <- "top"
  # center-top to right-center
  halign_out[center_top] <- "right"
  valign_out[center_top] <- "center"
  # right-top to right-bottom
  halign_out[right_top] <- "right"
  valign_out[right_top] <- "bottom"
  # left_middle to center-top
  halign_out[left_middle] <- "center"
  valign_out[left_middle] <- "top"
  # center_middle to center-center
  halign_out[center_middle] <- "center"
  valign_out[center_middle] <- "center"
  # right_middle to center-bottom
  halign_out[right_middle] <- "center"
  valign_out[right_middle] <- "bottom"
  # left_bottom to left-top
  halign_out[left_bottom] <- "left"
  valign_out[left_bottom] <- "top"
  # center_bottom to left-center
  halign_out[center_bottom] <- "left"
  valign_out[center_bottom] <- "center"
  # right_bottom to left-bottom
  halign_out[right_bottom] <- "left"
  valign_out[right_bottom] <- "bottom"

  left_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "left"
  center_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "center"
  right_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "right"
  left_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "left"
  center_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "center"
  right_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "right"
  left_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "left"
  center_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "center"
  right_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "right"

  # left-top to left-bottom
  halign_out[left_top] <- "left"
  valign_out[left_top] <- "bottom"
  # center-top to left-center
  halign_out[center_top] <- "left"
  valign_out[center_top] <- "center"
  # right-top to left-top
  halign_out[right_top] <- "left"
  valign_out[right_top] <- "top"

  # left_middle
  halign_out[left_middle] <- "center"
  valign_out[left_middle] <- "bottom"
  # center_middle
  halign_out[center_middle] <- "center"
  valign_out[center_middle] <- "center"
  # right_middle
  halign_out[right_middle] <- "center"
  valign_out[right_middle] <- "top"

  # left_bottom
  halign_out[left_bottom] <- "right"
  valign_out[left_bottom] <- "bottom"
  # center_bottom
  halign_out[center_bottom] <- "right"
  valign_out[center_bottom] <- "center"
  # right_bottom
  halign_out[right_bottom] <- "right"
  valign_out[right_bottom] <- "top"
  list(align = halign_out, valign = valign_out)
}
