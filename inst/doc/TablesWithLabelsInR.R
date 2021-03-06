## ---- message=FALSE, warning=FALSE---------------------------------------
library(expss)
data(mtcars)
mtcars = apply_labels(mtcars,
                      mpg = "Miles/(US) gallon",
                      cyl = "Number of cylinders",
                      disp = "Displacement (cu.in.)",
                      hp = "Gross horsepower",
                      drat = "Rear axle ratio",
                      wt = "Weight (1000 lbs)",
                      qsec = "1/4 mile time",
                      vs = "Engine",
                      vs = c("V-engine" = 0,
                             "Straight engine" = 1),
                      am = "Transmission",
                      am = c("Automatic" = 0,
                             "Manual"=1),
                      gear = "Number of forward gears",
                      carb = "Number of carburetors"
)


## ------------------------------------------------------------------------
# 'cro' examples
# multiple banners
mtcars %>% 
    calculate(cro_cpct(cyl, list(total(), am, vs))) %>% 
    htmlTable(caption = "Table with multiple banners (column %).")

# nested banners          
mtcars %>% 
    calculate(cro_cpct(cyl, list(total(), am %nest% vs))) %>% 
    htmlTable(caption = "Table with nested banners (column %).")         


## ------------------------------------------------------------------------
mtcars %>% 
    tab_cells(mpg, disp, hp, wt, qsec) %>%
    tab_cols(total(), am) %>% 
    tab_stat_fun(Mean = w_mean, "Std. dev." = w_sd, "Valid N" = w_n) %>%
    tab_pivot() %>% 
    htmlTable(caption = "Table with summary statistics. Statistics labels in rows.")

mtcars %>% 
    tab_cells(mpg, disp, hp, wt, qsec) %>%
    tab_cols(total(label = "#Total| |"), am) %>% 
    tab_stat_fun(Mean = w_mean, "Std. dev." = w_sd, "Valid N" = w_n, method = list) %>%
    tab_pivot() %>% 
    htmlTable(caption = "Table with the same summary statistics. Statistics labels in columns.")

mtcars %>%
    tab_cols(total(), vs) %>%
    tab_cells(mpg) %>% 
    tab_stat_mean() %>% 
    tab_stat_valid_n() %>% 
    tab_cells(am) %>%
    tab_stat_cpct(total_row_position = "none", label = "col %") %>%
    tab_stat_rpct(total_row_position = "none", label = "row %") %>%
    tab_stat_tpct(total_row_position = "none", label = "table %") %>%
    tab_pivot(stat_position = "inside_rows") %>% 
    htmlTable(caption = "Different statistics for differen variables.")

mtcars %>% 
    tab_cells(cyl) %>% 
    tab_cols(total(), vs) %>% 
    tab_rows(am) %>% 
    tab_stat_cpct(total_row_position = "above",
                  total_label = c("number of cases", "row %"),
                  total_statistic = c("u_cases", "u_rpct")) %>% 
    tab_pivot() %>% 
    htmlTable(caption = "Table with split by rows and with custom totals.")

mtcars %>% 
    tab_cells(dtfrm(mpg, disp, hp, wt, qsec)) %>% 
    tab_cols(total(label = "#Total| |"), am) %>% 
    tab_stat_fun_df(
        function(x){
            frm = reformulate(".", response = names(x)[1])
            model = lm(frm, data = x)
            dtfrm('Coef.' = coef(model), 
                  confint(model)
            )
        }    
    ) %>% 
    tab_pivot() %>% 
    htmlTable(caption = "Linear regression by groups.")

## ------------------------------------------------------------------------

data(product_test)

w = product_test # shorter name to save some keystrokes

# here we recode variables from first/second tested product to separate variables for each product according to their cells
# 'h' variables - VSX123 sample, 'p' variables - 'SDF456' sample
# also we recode preferences from first/second product to true names
# for first cell there are no changes, for second cell we should exchange 1 and 2.
w = w %>% 
    do_if(cell == 1, {
        recode(a1_1 %to% a1_6, other ~ copy) %into% (h1_1 %to% h1_6)
        recode(b1_1 %to% b1_6, other ~ copy) %into% (p1_1 %to% p1_6)
        recode(a22, other ~ copy) %into% h22
        recode(b22, other ~ copy) %into% p22
        c1r = c1
    }) %>% 
    do_if(cell == 2, {
        recode(a1_1 %to% a1_6, other ~ copy) %into% (p1_1 %to% p1_6)
        recode(b1_1 %to% b1_6, other ~ copy) %into% (h1_1 %to% h1_6)
        recode(a22, other ~ copy) %into% p22
        recode(b22, other ~ copy) %into% h22
        recode(c1, 1 ~ 2, 2 ~ 1, other ~ copy) %into% c1r
    }) %>% 
    compute({
        # recode age by groups
        age_cat = recode(s2a, lo %thru% 25 ~ 1, lo %thru% hi ~ 2)
        # count number of likes
        # codes 2 and 99 are ignored.
        h_likes = count_row_if(1 | 3 %thru% 98, h1_1 %to% h1_6) 
        p_likes = count_row_if(1 | 3 %thru% 98, p1_1 %to% p1_6) 
    })

# here we prepare labels for future usage
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

overall_liking_scale = num_lab("
    1 Extremely poor 
    2 Very poor
    3 Quite poor
    4 Neither good, nor poor
    5 Quite good
    6 Very good
    7 Excellent
")

w = apply_labels(w, 
    c1r = "Preferences",
    c1r = num_lab("
        1 VSX123 
        2 SDF456
        3 Hard to say
    "),
    
    age_cat = "Age",
    age_cat = c("18 - 25" = 1, "26 - 35" = 2),
    
    h1_1 = "Likes. VSX123",
    p1_1 = "Likes. SDF456",
    h1_1 = codeframe_likes,
    p1_1 = codeframe_likes,
    
    h_likes = "Number of likes. VSX123",
    p_likes = "Number of likes. SDF456",
    
    h22 = "Overall quality. VSX123",
    p22 = "Overall quality. SDF456",
    h22 = overall_liking_scale,
    p22 = overall_liking_scale
)


cro(w$c1r) %>% htmlTable(caption = "Distribution of preferences." )

## ------------------------------------------------------------------------
# 'na_if(c1r, 3)' remove 'hard to say' from vector 
w %>% calculate(c1r %>% na_if(3) %>% table %>% chisq.test) 

## ------------------------------------------------------------------------
w %>% 
    tab_cols(total(), age_cat) %>% 
    tab_cells(c1r) %>% 
    tab_stat_cpct() %>% 
    tab_pivot() %>% 
    htmlTable(caption = "Preferences")

w %>% 
    tab_cols(total(), age_cat, c1r) %>% 
    tab_cells(h22) %>% 
    tab_stat_mean(label = "<b><u>Mean</u></b>") %>% 
    tab_stat_cpct() %>% 
    tab_cells(p22) %>% 
    tab_stat_mean(label = "<b><u>Mean</u></b>") %>% 
    tab_stat_cpct() %>% 
    tab_pivot() %>% 
    htmlTable(caption = "Overall liking")

w %>% 
    tab_cols(total(), age_cat, c1r) %>% 
    tab_cells(h_likes) %>% 
    tab_stat_mean() %>% 
    tab_cells(mrset(h1_1 %to% h1_6)) %>% 
    tab_stat_cpct() %>% 
    tab_cells(p_likes) %>% 
    tab_stat_mean() %>% 
    tab_cells(mrset(p1_1 %to% p1_6)) %>% 
    tab_stat_cpct() %>% 
    tab_pivot() %>% 
    htmlTable(caption = "Likes") 

w %>% 
    tab_cols(total(label = "#Total| |"), c1r) %>% 
    tab_cells(list(unvr(mrset(h1_1 %to% h1_6)))) %>% 
    tab_stat_cpct(label = var_lab(h1_1)) %>% 
    tab_cells(list(unvr(mrset(p1_1 %to% p1_6)))) %>% 
    tab_stat_cpct(label = var_lab(p1_1)) %>% 
    tab_pivot(stat_position = "inside_columns") %>% 
    htmlTable(caption = "Likes - side by side comparison")  




## ---- eval=FALSE---------------------------------------------------------
#  write_labelled_csv(w, file  filename = "product_test.csv")

## ---- eval=FALSE---------------------------------------------------------
#  write_labelled_spss(w, file  filename = "product_test.csv")

## ------------------------------------------------------------------------
with(mtcars, table(am, vs)) %>% knitr::kable()

boxplot(mpg ~ am, data = mtcars)

## ---- message=FALSE, warning=FALSE, include=FALSE------------------------
library(expss)

## ---- results='hide', message=FALSE, warning=FALSE-----------------------
w = read.csv(text = "
a,b,c
2,15,50
1,70,80
3,30,40
2,30,40"
)


## ---- eval=FALSE---------------------------------------------------------
#  w$d = ifelse(w$b>60, 1, 0)

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = ifelse(b>60, 1, 0)
#      e = 42
#      abc_sum = sum_row(a, b, c)
#      abc_mean = mean_row(a, b, c)
#  })

## ---- eval=FALSE---------------------------------------------------------
#  count_if(1, w)

## ---- eval=FALSE---------------------------------------------------------
#  calculate(w, count_if(1, a, b, c))

## ---- eval=FALSE---------------------------------------------------------
#  w$d = count_row_if(gt(1), w)

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = count_row_if(gt(1), a, b, c)
#  })
#  

## ---- eval=FALSE---------------------------------------------------------
#  count_col_if(le(1), w$a)

## ---- eval=FALSE---------------------------------------------------------
#  sum(w, na.rm = TRUE)

## ---- eval=FALSE---------------------------------------------------------
#  w$d = mean_row(w)

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = mean_row(a, b, c)
#  })
#  

## ---- eval=FALSE---------------------------------------------------------
#  sum_col(w$a)

## ---- eval=FALSE---------------------------------------------------------
#  sum_if(gt(40), w)

## ---- eval=FALSE---------------------------------------------------------
#  calculate(w, sum_if(gt(40), a, b, c))

## ---- eval=FALSE---------------------------------------------------------
#  w$d = sum_row_if(lt(40), w)

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = sum_row_if(lt(40), a, b, c)
#  })
#  

## ---- eval=FALSE---------------------------------------------------------
#  mean_col_if(lt(3), w$a, data = w$b)

## ---- eval=FALSE---------------------------------------------------------
#  calculate(w, mean_col_if(lt(3), a, data = dtfrm(b, c)))

## ---- eval=FALSE---------------------------------------------------------
#  dict = read.csv(text = "
#  x,y
#  1,apples
#  2,oranges
#  3,peaches",
#  stringsAsFactors = FALSE
#  )

## ---- eval=FALSE---------------------------------------------------------
#  w$d = vlookup(w$a, dict, 2)

## ---- eval=FALSE---------------------------------------------------------
#  w$d = vlookup(w$a, dict, "y")

## ---- eval=FALSE---------------------------------------------------------
#  w$d = 1

## ---- results='hide', message=FALSE, warning=FALSE-----------------------
w = compute(w, {
    d = 1
})

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = ifelse(a == 3, 2, NA)
#  })

## ---- eval=FALSE---------------------------------------------------------
#  w = compute(w, {
#      d = ifs(a == 3 ~ 2)
#  })

## ---- eval=FALSE---------------------------------------------------------
#  w = do_if(w, a>1, {
#      d = 4
#  })

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(lo %thru% hi, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(NA, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(1 %thru% 5, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(1 %thru% hi, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(ge(1), a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(lo %thru% 1, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if (le(1), a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(1 %thru% 5 | 99, a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  cnt = count_row_if(c(1:5, NA), a1 %to% a5)

## ---- eval=FALSE---------------------------------------------------------
#  recode(v1) = c(0 ~ 1, 1 ~ 0, 2:3 ~ -1, 9 ~ 9, other ~ NA)

## ---- eval=FALSE---------------------------------------------------------
#  recode(qvar) = c(1 %thru% 5 ~ 1, 6 %thru% 10 ~ 2, 11 %thru% hi ~ 3, other ~ 0)

## ---- eval=FALSE---------------------------------------------------------
#  recode(strngvar) = c(c('A', 'B', 'C') ~ 'A', c('D', 'E', 'F') ~ 'B', other ~ ' ')

## ---- eval=FALSE---------------------------------------------------------
#  voter = recode(age, NA ~ 9, 18 %thru% hi ~ 1, 0 %thru% 18 ~ 0)
#  # or
#  recode(age, NA ~ 9, 18 %thru% hi ~ 1, 0 %thru% 18 ~ 0) %into% voter

## ---- results='hide'-----------------------------------------------------
w = apply_labels(w,
                 a = "Fruits",
                 b = "Cost",
                 c = "Price"
)

## ---- results='hide'-----------------------------------------------------
w = apply_labels(w, 
                 a = num_lab("
                        1 apples
                        2 oranges
                        3 peaches 
                    ")
)

## ---- eval=FALSE---------------------------------------------------------
#  val_lab(w$a) = num_lab("
#      1 apples
#      2 oranges
#      3 peaches
#  ")
#  

## ------------------------------------------------------------------------
fre(w$a) # Frequency of fruits
cro_cpct(w$b, w$a) # Column percent of cost by fruits
cro_mean(dtfrm(w$b, w$c), w$a) # Mean cost and price by fruits

