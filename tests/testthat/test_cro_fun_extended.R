context("cro_fun extended")


data(mtcars)
mtcars = modify(mtcars,{
    var_lab(mpg) = "Miles/(US) gallon"
    var_lab(cyl) = "Number of cylinders"
    var_lab(disp) = "Displacement (cu.in.)"
    var_lab(hp) = "Gross horsepower"
    var_lab(drat) = "Rear axle ratio"
    var_lab(wt) = "Weight (lb/1000)"
    var_lab(qsec) = "1/4 mile time"
    var_lab(vs) = "V/S"
    val_lab(vs) = c("Straight" = 0, "V" = 1)
    var_lab(am) = "Transmission (0 = automatic, 1 = manual)"
    val_lab(am) = c(" automatic" = 0, " manual" =  1)
    var_lab(gear) = "Number of forward gears"
    var_lab(carb) = "Number of carburetors"
})

# row_labels = c("row_vars", "row_vars_values", "summary_vars", "fun_names", "stat_names"),
# col_labels = c("col_vars", "col_vars_values")

# table_summary(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = mean)
# table_means(mtcars %except% c("cyl", "am"), col_vars = mtcars$am)
# table_medians(mtcars %except% c("cyl", "am"), col_vars = mtcars$am)
# table_sums(mtcars %except% c("cyl", "am"), col_vars = mtcars$am)
# table_sums(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, weight = 2)
# expect_error(cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, 
#                      fun = mean)
#              )
# expect_error(cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = mean))
# expect_error(cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = mean,
#               row_labels = c("stat_names", "col_vars_values", "row_vars", "row_vars_values", "summary_vars",  "col_vars"),
#               col_labels = c("adasd", "rvtrvtt")
# ))
# expect_error(cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = mean,
#               col_labels = c("stat_names", "col_vars_values", "row_vars", "row_vars_values", "summary_vars",  "col_vars"),
#               row_labels = c("adasd", "rvtrvtt")
# ))

#######
expect_error(
    cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = mean, weight = 2)
    )



expect_equal_to_reference(
    cro_fun(mtcars %except% c("cyl", "am"), col_vars = mtcars$am, fun = combine_functions(w_mean), weight = 2),
                          "rds/table_summary0.rds")


expect_equal_to_reference(
    cro_fun(mtcars %except% c("cyl", "am"), col_vars = list("Total", mtcars$am), 
            fun = combine_functions(mean)),
    "rds/table_summary1.rds"
    )


add_val_lab(mtcars$am) = c(HardToSay = 3)
expect_equal_to_reference(
    cro_fun(mtcars %except% c("cyl", "am"), col_vars = list("Total", mtcars$am), 
            fun = combine_functions(mean))
    ,"rds/table_summary2.rds"
)

data(mtcars)
mtcars = modify(mtcars,{
    var_lab(mpg) = "Miles/(US) gallon"
    var_lab(cyl) = "Number of cylinders"
    var_lab(disp) = "Displacement (cu.in.)"
    var_lab(hp) = "Gross horsepower"
    var_lab(drat) = "Rear axle ratio"
    var_lab(wt) = "Weight (lb/1000)"
    var_lab(qsec) = "1/4 mile time"
    var_lab(vs) = "V/S"
    val_lab(vs) = c("Straight" = 0, "V" = 1)
    var_lab(am) = "Transmission (0 = automatic, 1 = manual)"
    val_lab(am) = c(" automatic" = 0, " manual" =  1)
    var_lab(gear) = "Number of forward gears"
    var_lab(carb) = "Number of carburetors"
})

add_val_lab(mtcars$am) = c(HardToSay = 3)
expect_equal_to_reference(
cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
              fun = combine_functions(mean))
,"rds/table_summary3.rds"
)

expect_equal_to_reference(
cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
        fun = mean)
,"rds/table_summary4.rds"
)

expect_equal_to_reference(
cro_fun_df(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
               fun = function(x) {
                   res = t(colMeans(x) )
                   rownames(res) = "mean"
                   res
                       })
,"rds/table_summary5.rds"
)

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_labels = c("row_vars", "row_vars_values", "stat_names"),
#               col_labels = c("col_vars", "summary_vars", "col_vars_values"), fun = mean)
# ,"rds/table_summary6.rds"
# )


########## rowlabels

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#              fun = combine_functions(mean))
# ,"rds/table_summary7.rds"
# )


# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#               row_labels = c("row_vars", "row_vars_values", "summary_vars"),
#               col_labels = c("col_vars", "col_vars_values", "stat_names"), fun = mean)
# ,"rds/table_summary8.rds"
# )

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), 
#               col_vars = mtcars$vs,
#         row_vars = list("Total", mtcars$am), 
#         fun = mean)
# ,"rds/table_summary9.rds"
# )

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#               row_labels = c("row_vars", "row_vars_values",  "col_vars_values", "summary_vars", "stat_names"),
#               col_labels = c("col_vars"), fun = mean)
# ,"rds/table_summary10.rds"
# )
##############################
add_val_lab(mtcars$vs) = c("Don't know" = 88)

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs, fun = combine_functions(mean))
# ,"rds/table_summary11.rds"
# )

# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#               row_labels = c("row_vars", "row_vars_values", "summary_vars"),
#               col_labels = c("col_vars", "col_vars_values", "stat_names"), fun = mean)
# ,"rds/table_summary12.rds"
# )


# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#               row_labels = c("row_vars", "row_vars_values", "summary_vars", "stat_names"),
#               col_labels = c("col_vars", "col_vars_values", "summary_vars"), fun = mean)
# ,"rds/table_summary13.rds"
# )


expect_equal_to_reference(
cro_fun_df(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
              row_vars = mtcars$vs, 
        fun = function(x) {
            res = t(colMeans(x) )
            rownames(res) = "mean"
            res
        })
,"rds/table_summary14.rds"
)


# expect_equal_to_reference(
# cro_fun(mtcars %except% c("vs", "am"), col_vars = list("Total", mtcars$am),
#               row_vars = mtcars$vs,
#               row_labels = c("row_vars", "row_vars_values",  "col_vars_values", "summary_vars", "stat_names"),
#               col_labels = c("col_vars"), fun = mean)
# ,"rds/table_summary15.rds"
# )

#########
data("product_test")
w = product_test
codeframe_likes = num_lab("
                          1 Liked everything
                          2 Disliked everything
                          3 Chocolate
                          4 Appearance
                          5 Taste
                          6 Stuffing
                          7 Nuts
                          8 Consistency
                          98 Other
                          99 Hard to answer
                          ")

w = compute(w, {
    # recode age by groups
    age_cat = if_val(s2a, lo %thru% 25 ~ 1, lo %thru% hi ~ 2)
    
    # Apply labels
    
    var_lab(c1) = "Preferences"
    val_lab(c1) = num_lab("
                          1 VSX123 
                          2 SDF456
                          3 Hard to say
                          ")
    
    var_lab(age_cat) = "Age"
    val_lab(age_cat) = c("18 - 25" = 1, "26 - 35" = 2)
    
    var_lab(a1_1) = "Likes. VSX123"
    var_lab(b1_1) = "Likes. SDF456"
    val_lab(a1_1) = codeframe_likes
    val_lab(b1_1) = codeframe_likes
    
    var_lab(a22) = "Overall quality. VSX123"
    var_lab(b22) = "Overall quality. SDF456"
    val_lab(a22) = num_lab("
                           1 Extremely poor 
                           2 Very poor
                           3 Quite poor
                           4 Neither good, nor poor
                           5 Quite good
                           6 Very good
                           7 Excellent
                           ")
    val_lab(b22) = val_lab(a22)
})

expect_equal_to_reference(
calc(w, cro_fun(list(a22, b22), col_vars = mrset(a1_1 %to% a1_6), fun = combine_functions(w_mean)))
, "rds/table_summary16.rds"
)
expect_equal_to_reference(
calc(w, cro_fun(list(a22, b22), col_vars = list(list(mrset(a1_1 %to% a1_6))), 
                fun = combine_functions(w_mean)))
, "rds/table_summary16.rds"
)

expect_equal_to_reference(
    calc(w, cro_fun(list(a22, b22), col_vars = mdset(as.dichotomy(a1_1 %to% a1_6, keep_unused = TRUE)),
                    fun = combine_functions(w_mean)))
    , "rds/table_summary16.rds"
)

expect_equal_to_reference(
    calc(w, cro_fun(list(a22, b22), 
                          col_vars = list(list(mdset(as.dichotomy(a1_1 %to% a1_6, keep_unused = TRUE)))),
                    fun = combine_functions(w_mean)))
    , "rds/table_summary16.rds"
)

expect_equal_to_reference(
calc(w, cro_fun(list(a22, b22),
                      col_vars = list(total(label = "Total")),
                      row_vars = list(mrset(a1_1 %to% a1_6)),
                      fun = combine_functions(w_mean)))
, "rds/table_summary17.rds"
)
expect_identical(
    calc(w, cro_fun(list(a22, b22), col_vars = list("Total"),
                          row_vars = list(list(mrset(a1_1 %to% a1_6))), ### list(list)
                    fun = combine_functions(w_mean)))
    , calc(w, cro_fun(list(a22, b22), 
                      col_vars = list("Total"), 
                      row_vars = list(mrset(a1_1 %to% a1_6)), 
                      fun = combine_functions(w_mean)))
)

expect_identical(
    calc(w, cro_fun(list(a22, b22), col_vars = list("Total"),
                          row_vars =  mdset(as.dichotomy(a1_1 %to% a1_6, keep_unused = TRUE)),
                          fun = combine_functions(w_mean)))
       , calc(w, cro_fun(list(a22, b22), 
                           col_vars = list("Total"), 
                           row_vars = list(mrset(a1_1 %to% a1_6)), 
                           fun = combine_functions(w_mean)))
)
expect_identical(
    calc(w, cro_fun(list(a22, b22), col_vars = list("Total"),
                          row_vars =  list(list(mdset(as.dichotomy(a1_1 %to% a1_6, keep_unused = TRUE)))),
                          fun = combine_functions(w_mean)))
    , calc(w, cro_fun(list(a22, b22), 
                      col_vars = list("Total"), 
                      row_vars = list(mrset(a1_1 %to% a1_6)), 
                      fun = combine_functions(w_mean)))
)
# calc(w, fre(a1_1 %to% a1_6))
