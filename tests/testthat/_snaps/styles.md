# align() accepts default align argument when columns is not a multiple of 4

    structure(c("left", "left", "left", "left", "left", "left"), dim = c(1L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("left", "left", "left", "left", "left", "left", "left", 
    "left", "left", "left", "left", "left"), dim = c(2L, 6L), dimnames = list(
        NULL, c("mpg", "cyl", "disp", "hp", "drat", "wt")))

# align() accepts combinations of align arguments.

    structure(c("right", "right", "right", "right", "right", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("right", "right", "right", "right", "right", "right", 
    "right", "right", "right", "right", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("left", "right", "left", "center", "center", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("left", "left", "right", "right", "left", "left", 
    "center", "center", "center", "center", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("right", "right", "right", "right", "right", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("right", "right", "right", "right", "center", "center", 
    "right", "right", "left", "left", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("right", "right", "right", "right", "right", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("right", "right", "right", "right", "center", "center", 
    "right", "right", "left", "left", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("right", "right", "center", "right", "center", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("right", "right", "right", "right", "center", "center", 
    "right", "right", "center", "center", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("left", "center", "left", "center", "right", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("right", "right", "right", "right", "right", "right", 
    "right", "right", "right", "right", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

---

    structure(c("left", "right", "left", "center", "justify", "right"
    ), dim = c(1L, 6L), dimnames = list(NULL, c("mpg", "cyl", "disp", 
    "hp", "drat", "wt")))

---

    structure(c("left", "left", "right", "right", "left", "left", 
    "center", "center", "justify", "justify", "right", "right"), dim = c(2L, 
    6L), dimnames = list(NULL, c("mpg", "cyl", "disp", "hp", "drat", 
    "wt")))

# align() will error if invalid align and part arguments are supplied

    structure(c("left", "left", "left", "left", "left", "left", "left", 
    "left", "left", "left", "left", "left"), dim = c(2L, 6L), dimnames = list(
        NULL, c("mpg", "cyl", "disp", "hp", "drat", "wt")))

