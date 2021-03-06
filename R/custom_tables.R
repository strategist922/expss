### constants for intermediate_table


DATA  = "data"   
RESULT = "result"    
COL_VAR = "col_var"  
ROW_VAR = "row_var"     
CELL_VAR = "cell_var"   
SUBGROUP = "subgroup"   
WEIGHT  = "weight" 
STAT_LABELS = "stat_labels"
MIS_VAL = "mis_val"

#' Functions for tables constraction
#' 
#' Table construction consists of at least of three functions chained with 
#' \code{magrittr} pipe operator: \link[magrittr]{\%>\%}. At first we need to 
#' specify variables for which statistics will be computed with 
#' \code{tab_cells}. Secondary, we calculate statistics with one of 
#' \code{tab_stat_*} functions. And last, we finalize table creation with 
#' \code{tab_pivot}: \code{dataset \%>\% tab_cells(variable) \%>\%
#' tab_stat_cases() \%>\% tab_pivot()}. After that we can optionally sort table
#' with \link{tab_sort_asc}, drop empty rows/columns with \link{drop_rc} and 
#' transpose with \code{tab_transpose}. Generally, table is just a data.frame so
#' we can use arbitrary operations on it. Statistic is always calculated with 
#' the last cell, column/row variables, weight, missing values and subgroup. To 
#' define new variables we can call appropriate function one more time. 
#' \code{tab_pivot} defines how we combine different statistics and where 
#' statistic labels will appear - inside/outside rows/columns. See examples.
#' 
#' @details 
#' \itemize{
#' \item{\code{tab_cells}}{ variables on which percentage/cases/summary
#' functions will be computed. Use \link{mrset}/\link{mdset} for
#' multiple-response variables.}
#' \item{\code{tab_cols}}{ optional variables which breaks table by
#'   columns. Use \link{mrset}/\link{mdset} for
#' multiple-response variables.}
#' \item{\code{tab_rows}}{ optional variables which breaks table by rows. Use
#' \link{mrset}/\link{mdset} for multiple-response variables.}
#' \item{\code{tab_weight}}{ optional weight for the statistic.}
#' \item{\code{tab_mis_val}}{ optional missing values for the statistic. It will
#' be applied on variables specified by \code{tab_cells}. It works in the same
#' manner as \link{na_if}.}
#' \item{\code{tab_subgroup}}{ optional logical vector/expression which specify
#' subset of data for table.}
#' \item{\code{tab_stat_fun}, \code{tab_stat_fun_df}}{ \code{tab_stat_fun} 
#' applies function on each variable in cells separately, \code{tab_stat_fun_df}
#' gives to function each data.frame in cells as a whole
#' \link[data.table]{data.table} with all names converted to variable labels (if
#' labels exists). So it is not recommended to rely on original variables names
#' in your \code{fun}. You can provide several functions as arguments. They will
#' be combined as with \link{combine_functions}. So you can use \code{method}
#' argument. For details see documentation for \link{combine_functions}. }
#' \item{\code{tab_stat_cases}}{ calculate counts.}
#' \item{\code{tab_stat_cpct}, \code{tab_stat_cpct_responses}}{ calculate column
#' percent. These functions give different results only for multiple response
#' variables. For \code{tab_stat_cpct} base of percent is number of valid cases.
#' Case is considered as valid if it has at least one non-NA value. So for
#' multiple response variables sum of percent may be greater than 100. For 
#' \code{tab_stat_cpct_responses} base of percent is number of valid responses. 
#' Multiple response variables can have several responses for single case. Sum 
#' of percent of \code{tab_stat_cpct_responses} always equals to 100\%.}
#' \item{\code{tab_stat_rpct}}{ calculate row percent. Base
#' for percent is number of valid cases.}
#' \item{\code{tab_stat_tpct}}{ calculate table percent. Base
#' for percent is number of valid cases.}
#' \item{\code{tab_stat_mean}, \code{tab_stat_median}, \code{tab_stat_se},
#' \code{tab_stat_sum}, \code{tab_stat_min}, \code{tab_stat_max},
#' \code{tab_stat_sd}, \code{tab_stat_valid_n}, 
#' \code{tab_stat_unweighted_valid_n}}{ different summary statistics. NA's are
#' always omitted.}
#' \item{\code{tab_pivot}}{ finalize table creation and define how different
#' \code{tab_stat_*} will be combined}
#' \item{\code{tab_transpose}}{ transpose final table after \code{tab_pivot} or last
#' statistic.}}
#' @param data data.frame/intermediate_table  
#' @param ... vector/data.frame/list. Variables for tables. Use
#'   \link{mrset}/\link{mdset} for multiple-response variables.
#' @param label character. Label for the statistic in the \code{tab_stat_*}. 
#' @param weight numeric vector in \code{tab_weight}. Cases with NA's, negative
#'   and zero weights are removed before calculations.
#' @param subgroup logical vector in \code{tab_subgroup}. You can specify
#'   subgroup on which table will be computed.
#' @param total_label By default "#Total". You can provide several names - each
#'   name for each total statistics.
#' @param total_statistic  By default it is "u_cases" (unweighted cases). 
#'   Possible values are "u_cases", "u_responses", "u_cpct", "u_rpct", "u_tpct",
#'   "w_cases", "w_responses", "w_cpct", "w_rpct", "w_tpct". "u_" means
#'   unweighted statistics and "w_" means weighted statistics.
#' @param total_row_position Position of total row in the resulting table. Can
#'   be one of "below", "above", "none".
#' @param stat_position character one of the values \code{"outside_rows"}, 
#'   \code{"inside_rows"}, \code{"outside_columns"} or \code{"inside_columns"}.
#'   It defines how we will combine statistics in the table.
#' @param stat_label character one of the values \code{"inside"} or 
#'   \code{"outside"}. Where will be placed labels for the statistics relative
#'   to column names/row labels? See examples.
#' @return All of these functions return object of class 
#'   \code{intermediate_table} except \code{tab_pivot} which returns final
#'   result - object of class \code{etable}. Basically it's a data.frame but
#'   class is needed for custom methods.
#' @seealso \link{fre}, \link{cro}, \link{cro_fun}, \link{tab_sort_asc},
#'   \link{drop_empty_rows}.
#' @export
#'
#' @name tables
#' @examples
#' data(mtcars)
#' mtcars = apply_labels(mtcars,
#'                       mpg = "Miles/(US) gallon",
#'                       cyl = "Number of cylinders",
#'                       disp = "Displacement (cu.in.)",
#'                       hp = "Gross horsepower",
#'                       drat = "Rear axle ratio",
#'                       wt = "Weight (1000 lbs)",
#'                       qsec = "1/4 mile time",
#'                       vs = "Engine",
#'                       vs = c("V-engine" = 0,
#'                              "Straight engine" = 1),
#'                       am = "Transmission",
#'                       am = c("Automatic" = 0,
#'                              "Manual"=1),
#'                       gear = "Number of forward gears",
#'                       carb = "Number of carburetors"
#' )
#' # some examples from 'cro'
#' # simple example - generally with 'cro' it can be made with less typing
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(vs) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # split rows
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(vs) %>% 
#'     tab_rows(am) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # multiple banners
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), vs, am) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # nested banners
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), vs %nest% am) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # summary statistics
#' mtcars %>% 
#'     tab_cells(mpg, disp, hp, wt, qsec) %>%
#'     tab_cols(am) %>% 
#'     tab_stat_fun(Mean = w_mean, "Std. dev" = w_sd, "Valid N" = w_n) %>%
#'     tab_pivot()
#' 
#' # summary statistics - labels in columns
#' mtcars %>% 
#'     tab_cells(mpg, disp, hp, wt, qsec) %>%
#'     tab_cols(am) %>% 
#'     tab_stat_fun(Mean = w_mean, "Std. dev" = w_sd, "Valid N" = w_n, method = list) %>%
#'     tab_pivot()
#' 
#' # subgroup with droping empty columns
#' mtcars %>% 
#'     tab_subgroup(am == 0) %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), vs %nest% am) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot() %>% 
#'     drop_empty_columns()
#' 
#' # total position at the top of the table
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), vs) %>% 
#'     tab_rows(am) %>% 
#'     tab_stat_cpct(total_row_position = "above",
#'                   total_label = c("number of cases", "row %"),
#'                   total_statistic = c("u_cases", "u_rpct")) %>% 
#'     tab_pivot()
#' 
#' # this example cannot be made easily with 'cro'             
#' mtcars %>%
#'     tab_cells(am) %>%
#'     tab_cols(total(), vs) %>%
#'     tab_stat_cpct(total_row_position = "none", label = "col %") %>%
#'     tab_stat_rpct(total_row_position = "none", label = "row %") %>%
#'     tab_stat_tpct(total_row_position = "none", label = "table %") %>%
#'     tab_pivot(stat_position = "inside_rows")
#' 
#' # statistic labels inside columns             
#' mtcars %>%
#'     tab_cells(am) %>%
#'     tab_cols(total(), vs) %>%
#'     tab_stat_cpct(total_row_position = "none", label = "col %") %>%
#'     tab_stat_rpct(total_row_position = "none", label = "row %") %>%
#'     tab_stat_tpct(total_row_position = "none", label = "table %") %>%
#'     tab_pivot(stat_position = "inside_columns")
#' 
#' # stacked statistics
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), am) %>% 
#'     tab_stat_mean() %>%
#'     tab_stat_se() %>% 
#'     tab_stat_valid_n() %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # stacked statistics with different variables
#' mtcars %>% 
#'     tab_cols(total(), am) %>% 
#'     tab_cells(mpg, hp, qsec) %>% 
#'     tab_stat_mean() %>%
#'     tab_cells(cyl, carb) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_pivot()
#' 
#' # stacked statistics - label position outside row labels
#' mtcars %>% 
#'     tab_cells(cyl) %>% 
#'     tab_cols(total(), am) %>% 
#'     tab_stat_mean() %>%
#'     tab_stat_se %>% 
#'     tab_stat_valid_n() %>% 
#'     tab_stat_cpct(label = "Col %") %>% 
#'     tab_pivot(stat_label = "outside")
#'     
#' # example from 'cro_fun_df' - linear regression by groups with sorting 
#' mtcars %>% 
#'     tab_cells(dtfrm(mpg, disp, hp, wt, qsec)) %>% 
#'     tab_cols(total(), am) %>% 
#'     tab_stat_fun_df(
#'         function(x){
#'             frm = reformulate(".", response = names(x)[1])
#'             model = lm(frm, data = x)
#'             dtfrm('Coef. estimate' = coef(model), 
#'                   confint(model)
#'             )
#'         }    
#'     ) %>% 
#'     tab_pivot() %>% 
#'     tab_sort_desc()
#' 
#' # multiple-response variables and weight
#' data(product_test)
#' codeframe_likes = num_lab("
#'                           1 Liked everything
#'                           2 Disliked everything
#'                           3 Chocolate
#'                           4 Appearance
#'                           5 Taste
#'                           6 Stuffing
#'                           7 Nuts
#'                           8 Consistency
#'                           98 Other
#'                           99 Hard to answer
#'                           ")
#' 
#' set.seed(1)
#' product_test = compute(product_test, {
#'     # recode age by groups
#'     age_cat = recode(s2a, lo %thru% 25 ~ 1, lo %thru% hi ~ 2)
#'     
#'     var_lab(age_cat) = "Age"
#'     val_lab(age_cat) = c("18 - 25" = 1, "26 - 35" = 2)
#'     
#'     var_lab(a1_1) = "Likes. VSX123"
#'     var_lab(b1_1) = "Likes. SDF456"
#'     val_lab(a1_1) = codeframe_likes
#'     val_lab(b1_1) = codeframe_likes
#'     
#'     wgt = runif(.N, 0.25, 4)
#'     wgt = wgt/sum(wgt)*.N
#' })
#' 
#' product_test %>% 
#'     tab_cells(mrset(a1_1 %to% a1_6), mrset(b1_1 %to% b1_6)) %>% 
#'     tab_cols(total(), age_cat) %>% 
#'     tab_weight(wgt) %>% 
#'     tab_stat_cpct() %>% 
#'     tab_sort_desc() %>% 
#'     tab_pivot()
#'     
#' # trick to place cell variables labels inside columns
#' # useful to compare two variables
#' # '|' is needed to prevent automatic labels creation from argument
#' # alternatively we can use list(...) to avoid this
#' product_test %>% 
#'     tab_cols(total(), age_cat) %>% 
#'     tab_weight(wgt) %>% 
#'     tab_cells("|" = unvr(mrset(a1_1 %to% a1_6))) %>% 
#'     tab_stat_cpct(label = var_lab(a1_1)) %>% 
#'     tab_cells("|" = unvr(mrset(b1_1 %to% b1_6))) %>% 
#'     tab_stat_cpct(label = var_lab(b1_1)) %>% 
#'     tab_pivot(stat_position = "inside_columns")
#' 
#' # if you need standard evaluation, use 'vars'
#' tables = mtcars %>%
#'       tab_cols(total(), am %nest% vs)
#' 
#' for(each in c("mpg", "disp", "hp", "qsec")){
#'     tables = tables %>% tab_cells(vars(each)) %>%
#'         tab_stat_fun(Mean = w_mean, "Std. dev" = w_sd, "Valid N" = w_n) 
#' }
#' tables %>% tab_pivot()
tab_cols = function(data, ...){
    UseMethod("tab_cols")
}


#' @export
tab_cols.data.frame = function(data, ...){
    res = make_empty_intermediate_table(data)
    tab_cols(res, ...)
}

#' @export
tab_cols.intermediate_table = function(data, ...){
    args = eval(substitute(calculate(data[["data"]], list(...))),
                envir = parent.frame(),
                enclos = baseenv())
    args = add_names_to_list(args, ...)
    if(length(args)>0){
        args = flat_list(args, flat_df = FALSE)
        data[[COL_VAR]] = args
    } else {
        data[[COL_VAR]] = list(total())    
    }
    data
}



######

#' @rdname tables
#' @export
tab_cells = function(data, ...){
    UseMethod("tab_cells")
}


#' @export
tab_cells.data.frame = function(data, ...){
    res = make_empty_intermediate_table(data)
    tab_cells(res, ...)
}

#' @export
tab_cells.intermediate_table = function(data, ...){
    # expr = substitute(create_list_with_names(...))
    # args = eval(bquote(calculate(data[["data"]], .(expr))))
    # expr = substitute(list(...))
    args = eval(substitute(calculate(data[["data"]], list(...))),
                envir = parent.frame(),
                enclos = baseenv())
    args = add_names_to_list(args, ...)
    if(length(args)>0){
        args = flat_list(args, flat_df = FALSE)
        data[[CELL_VAR]] = args
    } else {
        data[[CELL_VAR]] = list(total())    
    }
    data
}

#########

#' @rdname tables
#' @export
tab_rows = function(data, ...){
    UseMethod("tab_rows")
}


#' @export
tab_rows.default = function(data, ...){
    res = make_empty_intermediate_table(data)
    tab_rows(res, ...)
}



#' @export
tab_rows.intermediate_table = function(data, ...){
    # expr = substitute(create_list_with_names(...))
    # args = eval(bquote(calculate(data[["data"]], .(expr))))
    # expr = substitute(list(...))
    args = eval(substitute(calculate(data[["data"]], list(...))),
                envir = parent.frame(),
                enclos = baseenv())
    args = add_names_to_list(args, ...)
    if(length(args)>0){
        args = flat_list(multiples_to_single_columns_with_dummy_encoding(args),
                         flat_df = TRUE)
        data[[ROW_VAR]] = args
    } else {
        data[[ROW_VAR]] = list(total())    
    }
    data
}

#########

#' @rdname tables
#' @export
tab_weight = function(data, weight = NULL){
    UseMethod("tab_weight")
}

#' @export
tab_weight.default = function(data, weight = NULL){
    res = make_empty_intermediate_table(data)
    # expr = substitute(weight)
    eval(substitute(tab_weight(res, weight)),
         envir = parent.frame(),
         enclos = baseenv())
}

#' @export
tab_weight.intermediate_table = function(data, weight = NULL){
    # expr = substitute(weight)
    weight = eval(substitute(calculate(data[["data"]], weight)),
                  envir = parent.frame(),
                  enclos = baseenv())
    if(is.null(weight)){
        data[[WEIGHT]] = NULL
    } else {
        stopif(!is.numeric(weight) && !is.logical(weight), "'weight' should be numeric or logical.")
        data[[WEIGHT]] = weight
    }
    data
}

############

#' @rdname tables
#' @export
tab_mis_val = function(data, ...){
    UseMethod("tab_mis_val")
}

#' @export
tab_mis_val.default = function(data, ...){
    res = make_empty_intermediate_table(data)
    tab_mis_val(res, ...)
}

#' @export
tab_mis_val.intermediate_table = function(data, ...){
    # expr = substitute(weight)
    args = eval(substitute(calculate(data[["data"]], list(...))),
                envir = parent.frame(),
                enclos = baseenv())
    if(length(args)>0){
        data[[MIS_VAL]] = unlist(args)
    } else {
        data[[MIS_VAL]] = NULL
    }
    data
}

#########

#' @rdname tables
#' @export
tab_subgroup = function(data, subgroup = NULL){
    UseMethod("tab_subgroup")
}

#' @export
tab_subgroup.default = function(data, subgroup = NULL){
    res = make_empty_intermediate_table(data)
    # expr = substitute(subgroup)
    eval(substitute(tab_subgroup(res, subgroup)),
         envir = parent.frame(),
         enclos = baseenv())
}

#' @export
tab_subgroup.intermediate_table = function(data, subgroup = NULL){
    # expr = substitute(subgroup)
    subgroup = eval(substitute(calculate(data[["data"]], subgroup)),
                  envir = parent.frame(),
                  enclos = baseenv())
    if(is.null(subgroup)){
        data[[SUBGROUP]] = NULL
    } else {
        stopif(!is.numeric(subgroup) && !is.logical(subgroup), "'subgroup' should be numeric or logical.")
        data[[SUBGROUP]] = subgroup
    }
    data
}


#####################
#' @rdname tables
#' @export
tab_stat_fun = function(data, ..., 
                        label = NULL){
    UseMethod("tab_stat_fun")
}

#' @rdname tables
#' @export
tab_stat_fun_df = function(data, ..., 
                           label = NULL){
    UseMethod("tab_stat_fun_df")
}

#' @rdname tables
#' @export
tab_stat_cases = function(data, 
                          total_label = NULL,
                          total_statistic = "u_cases",
                          total_row_position = c("below", "above", "none"),
                          label = NULL){
    UseMethod("tab_stat_cases")
}

#' @rdname tables
#' @export
tab_stat_cpct = function(data, 
                         total_label = NULL,
                         total_statistic = "u_cases",
                         total_row_position = c("below", "above", "none"),
                         label = NULL){
    UseMethod("tab_stat_cpct")
}

#' @rdname tables
#' @export
tab_stat_cpct_responses =function(data, 
                                  total_label = NULL,
                                  total_statistic = "u_responses",
                                  total_row_position = c("below", "above", "none"),
                                  label = NULL){
    UseMethod("tab_stat_cpct_responses")
}

#' @rdname tables
#' @export
tab_stat_tpct = function(data, 
                         total_label = NULL,
                         total_statistic = "u_cases",
                         total_row_position = c("below", "above", "none"),
                         label = NULL){
    UseMethod("tab_stat_tpct")
}

#' @rdname tables
#' @export
tab_stat_rpct = function(data, 
                         total_label = NULL,
                         total_statistic = "u_cases",
                         total_row_position = c("below", "above", "none"),
                         label = NULL){
    UseMethod("tab_stat_rpct")
}

############
#' @export
tab_stat_fun.intermediate_table = function(data, ..., 
                                label = NULL){
    # fun = eval(substitute(combine_functions(...)))
    args = list(...)
    if(length(args)>1 || !is.null(names(args))){
        fun = combine_functions(...)
    } else {
        fun = args[[1]]
    }
    # label = substitute(label)
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_fun(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        fun = fun
    )
    add_result_to_intermediate_table(data, result, label)
}

#' @rdname tables
#' @export
tab_stat_mean = function(data, label = "Mean"){
    eval(substitute(tab_stat_fun(data, 
                             w_mean, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_median = function(data, label = "Median"){
    eval(substitute(tab_stat_fun(data, 
                             w_median, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_se = function(data, label = "S. E."){
    eval(substitute(tab_stat_fun(data,
                             w_se, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_sum = function(data, label = "Sum"){
    eval(substitute(tab_stat_fun(data, 
                             w_sum, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_min = function(data, label = "Min."){
    eval(substitute(tab_stat_fun(data, 
                                 w_min, 
                                 label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_max = function(data, label = "Max."){
    eval(substitute(tab_stat_fun(data, 
                                 w_max, 
                                 label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_sd = function(data, label = "Std. dev."){
    eval(substitute(tab_stat_fun(data, 
                             w_sd, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())
}

#' @rdname tables
#' @export
tab_stat_valid_n = function(data, label = "Valid N"){
    eval(substitute(tab_stat_fun(data, 
                             valid_n, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}

#' @rdname tables
#' @export
tab_stat_unweighted_valid_n = function(data, label = "Unw. valid N"){
    eval(substitute(tab_stat_fun(data, 
                             unweighted_valid_n, 
                             label = label)),
         envir = parent.frame(),
         enclos = baseenv())    
}


#' @export
tab_stat_fun_df.intermediate_table = function(data, ..., 
                                   label = NULL){
    
    # fun = eval(substitute(combine_functions(...)))
    args = list(...)
    if(length(args)>1 || !is.null(names(args))){
        fun = combine_functions(...)
    } else {
        fun = args[[1]]
    }
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_fun_df(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        fun = fun
    )
    add_result_to_intermediate_table(data, result, label)
}

#' @export
tab_stat_cases.intermediate_table = function(data, 
                                  total_label = NULL,
                                  total_statistic = "u_cases",
                                  total_row_position = c("below", "above", "none"),
                                  label = NULL){
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_cases(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        total_label = total_label,
        total_statistic = total_statistic,
        total_row_position = total_row_position
    )
    add_result_to_intermediate_table(data, result, label)
}

#' @export
tab_stat_cpct.intermediate_table = function(data, 
                                 total_label = NULL,
                                 total_statistic = "u_cases",
                                 total_row_position = c("below", "above", "none"),
                                 label = NULL){
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_cpct(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        total_label = total_label,
        total_statistic = total_statistic,
        total_row_position = total_row_position
    )
    add_result_to_intermediate_table(data, result, label)
}


#' @export
tab_stat_cpct_responses.intermediate_table =function(data, 
                                          total_label = NULL,
                                          total_statistic = "u_responses",
                                          total_row_position = c("below", "above", "none"),
                                          label = NULL){
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_cpct_responses(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        total_label = total_label,
        total_statistic = total_statistic,
        total_row_position = total_row_position
    )
    add_result_to_intermediate_table(data, result, label)
}

#' @export
tab_stat_tpct.intermediate_table = function(data, 
                                 total_label = NULL,
                                 total_statistic = "u_cases",
                                 total_row_position = c("below", "above", "none"),
                                 label = NULL){
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_tpct(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        total_label = total_label,
        total_statistic = total_statistic,
        total_row_position = total_row_position
    )
    add_result_to_intermediate_table(data, result, label)
}

#' @export
tab_stat_rpct.intermediate_table = function(data, 
                                            total_label = NULL,
                                            total_statistic = "u_cases",
                                            total_row_position = c("below", "above", "none"),
                                            label = NULL){
    label = eval(substitute(calculate(data[["data"]], label)),
                 envir = parent.frame(),
                 enclos = baseenv())
    result = cro_rpct(
        cell_vars = get_cells(data),
        col_vars = data[[COL_VAR]],
        row_vars = data[[ROW_VAR]],
        weight = data[[WEIGHT]],
        subgroup = data[[SUBGROUP]],
        total_label = total_label,
        total_statistic = total_statistic,
        total_row_position = total_row_position
    )
    add_result_to_intermediate_table(data, result, label)
}

######
############
#' @export
tab_stat_fun.default = function(data, ..., 
                        label = NULL){
    tab_stat_()
}

#' @export
tab_stat_fun_df.default = function(data, ..., 
                           label = NULL){
    tab_stat_()
}

#' @export
tab_stat_cases.default = function(data, 
                          total_label = NULL,
                          total_statistic = "u_cases",
                          total_row_position = c("below", "above", "none"),
                          label = NULL){
    tab_stat_()
}

#' @export
tab_stat_cpct.default = function(data, 
                         total_label = NULL,
                         total_statistic = "u_cases",
                         total_row_position = c("below", "above", "none"),
                         label = NULL){
    tab_stat_()
}


#' @export
tab_stat_cpct_responses.default =function(data, 
                                  total_label = NULL,
                                  total_statistic = "u_responses",
                                  total_row_position = c("below", "above", "none"),
                                  label = NULL){
    tab_stat_()
}

#' @export
tab_stat_tpct.default = function(data, 
                         total_label = NULL,
                         total_statistic = "u_cases",
                         total_row_position = c("below", "above", "none"),
                         label = NULL){
    tab_stat_()
}

#' @export
tab_stat_rpct.default = function(data, 
                                 total_label = NULL,
                                 total_statistic = "u_cases",
                                 total_row_position = c("below", "above", "none"),
                                 label = NULL){
    tab_stat_()
}

######
tab_stat_ = function(){
    stop("No data for 'tab_stat_*'. Use at least one of 'tab_cells'/'tab_rows'/'tab_cols' before the 'tab_stat'.")
}

########
#' @rdname tables
#' @export
tab_pivot = function(data, stat_position = c("outside_rows",
                                             "inside_rows",
                                             "outside_columns",
                                             "inside_columns"), 
                     stat_label = c("inside", "outside")){
    UseMethod("tab_pivot")
}

#' @export
tab_pivot.intermediate_table = function(data, stat_position = c("outside_rows",
                                                       "inside_rows",
                                                       "outside_columns",
                                                       "inside_columns"), 
                                        stat_label = c("inside", "outside")){
    stopif(length(data[[RESULT]])==0, 
           "No statistics in the table. Use at least one of 'tab_stat' before the 'pivot'.")
    stat_position = match.arg(stat_position)
    res = switch(stat_position, 
                 outside_rows = pivot_rows(data, stat_position = "outside", 
                                           stat_label = stat_label),
                 inside_rows = pivot_rows(data, stat_position = "inside", 
                                          stat_label = stat_label),
                 outside_columns = pivot_columns(data, stat_position = "outside", 
                                                 stat_label = stat_label),
                 inside_columns = pivot_columns(data, stat_position = "inside", 
                                                stat_label = stat_label)
    )
    res[["row_labels"]] = remove_unnecessary_splitters(res[["row_labels"]])
    colnames(res) = remove_unnecessary_splitters(colnames(res))
    rownames(res) = NULL
    res
}

#' @export
tab_pivot.default = function(data, stat_position = c("outside_rows",
                                                     "inside_rows",
                                                     "outside_columns",
                                                     "inside_columns"), 
                             stat_label = c("inside", "outside")
                             ){
    stop("No data for 'tab_pivot'. 
         Use at least one of 'tab_cells'/'tab_rows'/'tab_cols' and at least one of 'tab_stat' before the 'tab_pivot'.")
}

#' @rdname tables
#' @export
tab_transpose = function(data){
    UseMethod("tab_transpose")
}

#' @export
tab_transpose.default = function(data){
    t(data)
}

#' @export
tab_transpose.intermediate_table = function(data){
    result_num = length(data[[RESULT]])
    stopif(result_num==0,
           "No results for transposition. Use 'tab_transpose' after 'tab_stat_*' or after 'tab_pivot'.")
    data[[RESULT]][[result_num]] = t(data[[RESULT]][[result_num]])
    data
}
# ########
# #' @rdname tables
# #' @export
# tab_intermediate_pivot = function(data, stat_position = c("outside_rows",
#                                                           "inside_rows",
#                                                           "outside_columns",
#                                                           "inside_columns"), 
#                                   stat_label = c("inside", "outside")
# ){
#     UseMethod("tab_intermediate_pivot")
#     
# }
# 
# #' @export
# tab_intermediate_pivot.intermediate_table = function(data, stat_position = c("outside_rows",
#                                                                              "inside_rows",
#                                                                              "outside_columns",
#                                                                              "inside_columns"), 
#                                                      stat_label = c("inside", "outside"),
#                                                      label = NULL
# ){
#     stopif(length(data[[RESULT]])==0, 
#            "No statistics in the table. Use at least one of 'tab_stat' before the 'pivot'.")
#     res = tab_pivot(data, stat_position = stat_position, stat_label = stat_label)
#     data[[RESULT]] = list(res)
#     data[[STAT_LABELS]] = if_null(label, "")
#     data
# }
# 
# #' @export
# tab_intermediate_pivot.default = function(data, stat_label_position = c("outside_rows",
#                                                            "inside_rows", 
#                                                            "outside_columns", 
#                                                            "inside_columns")
# ){
#     stop("No data for 'tab_pivot'. 
#          Use at least one of 'tab_cells'/'tab_rows'/'tab_cols' and at least one of 'tab_stat' before the 'tab_pivot'.")
# }
################

pivot_rows = function(data, stat_position = c("inside", "outside"), 
                      stat_label = c("inside", "outside")){
    stat_position = match.arg(stat_position)  
    stat_label = match.arg(stat_label)  
    results = data[[RESULT]]
    labels = data[[STAT_LABELS]]
    labels_index = seq_along(labels)
    
    results = lapply(labels_index, function(item_num){
        curr = results[[item_num]]
        curr[["..label_index__"]] = item_num
        curr[["..label__"]] = labels[item_num]
        curr
    })
    results = Reduce(add_rows, results)

    if(stat_position == "inside"){
        results[["..row_labels__"]] = match(results[["row_labels"]], 
                                            unique(results[["row_labels"]])
        )
        results = sort_asc(results, "..row_labels__", "..label_index__")
        
        results[["..row_labels__"]] = NULL
    }
    if(stat_label == "inside"){
        results[["row_labels"]] = paste0( results[["row_labels"]], "|", results[["..label__"]])     
    } else {
        results[["row_labels"]] = paste0( results[["..label__"]], "|", results[["row_labels"]])
    }
    
    results[["..label__"]] = NULL
    results[["..label_index__"]] = NULL
    results
    
}

################

pivot_columns = function(data, stat_position = c("inside", "outside"), 
                         stat_label = c("inside", "outside")){
    stat_position = match.arg(stat_position)  
    stat_label = match.arg(stat_label)   
    results = data[[RESULT]]
    labels = data[[STAT_LABELS]]
    labels_index = seq_along(labels)
    
    all_colnames = unlist(lapply(results, function(item) colnames(item)[-1]))
    colnames_index = match(all_colnames, unique(all_colnames))
    results_ncols = vapply(results, NCOL, FUN.VALUE = numeric(1)) - 1 # 'row_labels' excluded
    
    results = lapply(labels_index, function(item_num){
        curr = results[[item_num]]
        if(stat_label == "inside"){
            colnames(curr)[-1] = paste0(colnames(curr)[-1], "|", labels[item_num])
        } else {
            colnames(curr)[-1] = paste0(labels[item_num], "|", colnames(curr)[-1])
        }
        curr
    })
    
    results = Reduce(merge, results)
    
    labels_index = rep.int(labels_index, times = results_ncols)
    if(stat_position == "inside"){
        new_order = order(colnames_index, labels_index, decreasing = FALSE)
    } else {
        new_order = order(labels_index, colnames_index, decreasing = FALSE)   
    }
    old_colnames = colnames(results)
    results = results[, c(1, new_order + 1), drop = FALSE]
    colnames(results) = old_colnames[c(1, new_order + 1)]
    results
    
}

#############

add_result_to_intermediate_table = function(data, result, label){
    new_result_position = length(data[[RESULT]]) + 1
    label = if_null(label, "")
    data[[RESULT]][[new_result_position]] = result
    data[[STAT_LABELS]][[new_result_position]] = label
    data
}

#############
make_empty_intermediate_table = function(data){
    res = list()
    res[["data"]] = data
    res[[COL_VAR]] = list(total())
    res[[ROW_VAR]] = list(total(label = ""))
    res[[CELL_VAR]] = list(total())
    res[[SUBGROUP]] = NULL
    res[[WEIGHT]] = NULL
    res[[MIS_VAL]] = NULL
    res[[RESULT]] = list()
    res[[STAT_LABELS]] = character(0)
    class(res) = union("intermediate_table", class(res))
    res
    
}

##############

get_cells = function(intermediate_table){
    cells = intermediate_table[[CELL_VAR]]
    mis_val = intermediate_table[[MIS_VAL]]
    if(is.list(mis_val) && length(mis_val)==1){
        mis_val = mis_val[[1]]
    }
    na_if(cells, mis_val)
}

##############

#' @export
print.intermediate_table = function(x, ...){
    cat("Object of class 'intermediate_table'. Use 'tab_pivot' to finish table creation.\n")
}

###############
add_names_to_list = function(args, ...){
    if(length(args)==0) return(NULL)
    possible_names = unlist(lapply(as.list(substitute(list(...)))[-1], deparse))
    arg_names = names(args)
    if(length(possible_names)>0){
        if(is.null(arg_names)) {
            names(args) = possible_names
        } else {
            names(args)[arg_names==""] = possible_names[arg_names==""]
        } 
    }
    for(each_item in seq_along(names(args))){
        curr_args = args[[each_item]]
        if(!is.list(curr_args) && 
           !is.data.frame(curr_args) && 
           !is.function(curr_args) && 
           !is.matrix(curr_args)){
            curr_lab = var_lab(curr_args)
            if(is.null(curr_lab)){
                var_lab(args[[each_item]]) = names(args)[[each_item]]
            }
        } else {
            names(args)[each_item] = ""
        }
        
    }
    args
}