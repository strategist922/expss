#' Cross-tabulation with custom summary function.
#' 
#' \itemize{
#' \item{\code{cro_mean}, \code{cro_sum}, \code{cro_median}}{ calculate 
#' mean/sum/median by groups. NA's are always omitted.}
#' \item{\code{cro_pearson}, \code{cro_spearman}}{ calculate correlation of 
#' first variable in each data.frame in \code{cell_vars} with other variables. 
#' NA's are removed pairwise.}
#' \item{\code{cro_fun}, \code{cro_fun_df}}{ return table with custom summary 
#' statistics defined by \code{fun} argument. NA's treatment depends on your 
#' \code{fun} behavior. To use weight you should have formal \code{weight} 
#' argument in \code{fun} and some logic for its processing inside. Several 
#' functions with weight support are provided - see \link{w_mean}. 
#' \code{cro_fun} applies \code{fun} on each variable in \code{cell_vars} 
#' separately, \code{cro_fun_df} gives to \code{fun} each data.frame in 
#' \code{cell_vars} as a whole. So \code{cro_fun(iris[, -5], iris$Species, fun =
#' mean)} gives the same result as \code{cro_fun_df(iris[, -5], iris$Species, 
#' fun = colMeans)}. For \code{cro_fun_df} names of \code{cell_vars} will 
#' converted to labels if they are available before \code{fun} will be applied.
#' Generally it is recommended that \code{fun} will always return object of the
#' same form. Row names/vector names of \code{fun} result will appear in the row
#' labels of the table and column names/names of list will appear in the column
#' labels.}
#' \item{\code{combine_functions}}{ is auxiliary function for combining several 
#' functions into one function for usage with \code{cro_fun}/\code{cro_fun_df}.
#' Names of arguments will be used as statistic labels. By default, results of
#' each function are combined with \link{c}. But you can provide your own method
#' function with \code{method} argument. It will be applied as in the expression
#' \code{do.call(method, list_of_functions_results)}. Particular useful method
#' is \code{list}. When it used statistic labels will appear in the column
#' labels. See examples. Also you may be interested in \code{data.frame}, 
#' \code{rbind}, \code{cbind} methods.}}
#' 
#' @param cell_vars vector/data.frame/list. Variables on which summary function
#'   will be computed. 
#' @param col_vars vector/data.frame/list. Variables which breaks table by
#'   columns. Use \link{mrset}/\link{mdset} for multiple-response variables.
#' @param row_vars vector/data.frame/list. Variables which breaks table by rows.
#'   Use \link{mrset}/\link{mdset} for multiple-response variables.
#' @param weight numeric vector. Optional cases weights. Cases with NA's,
#'   negative and zero weights are removed before calculations.
#' @param subgroup logical vector. You can specify subgroup on which table will be computed. 
#' @param fun custom summary function. Generally it is recommended that 
#'   \code{fun} will always return object of the same form. Rownames/vector 
#'   names of \code{fun} result will appear in the row labels of the table and 
#'   column names/names of list will appear in the column labels. To use weight 
#'   you should have formal \code{weight} argument in \code{fun} and some logic 
#'   for its processing inside. For \code{cro_fun_df} \code{fun} will receive 
#'   \link[data.table]{data.table} with all names converted to variable labels
#'   (if labels exists). So it is not recommended to rely on original variables
#'   names in your \code{fun}.
#' @param ... further arguments for \code{fun}  in
#'   \code{cro_fun}/\code{cro_fun_df} or functions for \code{combine_functions}.
#' @param method function which will combine results of multiple functions in
#'   \code{combine_functions}. It will be applied as in the expression 
#'   \code{do.call(method, list_of_functions_results)}. By default it is
#'   \code{c}.
#'
#' @return object of class 'etable'. Basically it's a data.frame but class
#'   is needed for custom methods.
#' @seealso \link{tables}, \link{fre}, \link{cro}.
#'
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
#' 
#' 
#' # Simple example - there is special shortcut for it - 'cro_mean'
#' calculate(mtcars, cro_fun(list(mpg, disp, hp, wt, qsec), 
#'                                col_vars = list(total(), am), 
#'                                row_vars = vs, 
#'                                fun = mean)
#' )
#' 
#' # The same example with 'subgroup'
#' calculate(mtcars, cro_fun(list(mpg, disp, hp, wt, qsec), 
#'                                col_vars = list(total(), am), 
#'                                row_vars = vs,
#'                                subgroup = vs == 0, 
#'                                fun = mean)
#' )
#'                                 
#' # 'combine_functions' usage  
#' calculate(mtcars, cro_fun(list(mpg, disp, hp, wt, qsec), 
#'                           col_vars = list(total(), am), 
#'                           row_vars = vs, 
#'                           fun = combine_functions(Mean = mean, 
#'                                                   'Std. dev.' = sd,
#'                                                   'Valid N' = valid_n)
#' ))  
#' # 'combine_functions' usage - statistic labels in columns
#' calculate(mtcars, cro_fun(list(mpg, disp, hp, wt, qsec), 
#'                           col_vars = list(total(), am), 
#'                           row_vars = vs, 
#'                           fun = combine_functions(Mean = mean, 
#'                                                   'Std. dev.' = sd,
#'                                                   'Valid N' = valid_n,
#'                                                   method = list
#'                                                   )
#' )) 
#' 
#' # 'summary' function
#' calculate(mtcars, cro_fun(list(mpg, disp, hp, wt, qsec), 
#'                           col_vars = list(total(), am), 
#'                           row_vars = list(total(), vs), 
#'                           fun = summary
#' ))  
#'                           
#' # comparison 'cro_fun' and 'cro_fun_df'
#' calculate(mtcars, cro_fun(dtfrm(mpg, disp, hp, wt, qsec), 
#'                        col_vars = am, fun = mean)
#' )
#' 
#' # same result
#' calculate(mtcars, cro_fun_df(dtfrm(mpg, disp, hp, wt, qsec), 
#'                        col_vars = am, fun = colMeans)
#' ) 
#' 
#' # usage for 'cro_fun_df' which is not possible for 'cro_fun'
#' # linear regression by groups
#' calculate(mtcars, cro_fun_df(dtfrm(mpg, disp, hp, wt, qsec), 
#'                              col_vars = am,
#'                              fun = function(x){
#'                                  frm = reformulate(".", response = names(x)[1])
#'                                  model = lm(frm, data = x)
#'                                  dtfrm('Coef. estimate' = coef(model), 
#'                                        confint(model)
#'                                  )
#'                              }
#' ))
#' @export
cro_fun = function(cell_vars, 
                   col_vars = total(), 
                   row_vars = total(label = ""),
                   weight = NULL,
                   subgroup = NULL,
                   fun, 
                   ...){
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_dataframe(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    fun = match.fun(fun)
    if(!is.null(weight)){
        stopif(!("weight" %in% names(formals(fun))),
               "`weight` is provided but `fun` doesn't have formal `weight` argument.")
    }
    fun = make_function_for_cro(fun, ..., need_weight = !is.null(weight))
    
    row_vars = flat_list(multiples_to_single_columns_with_dummy_encoding(row_vars), flat_df = TRUE)
    col_vars = flat_list(multiples_to_single_columns_with_dummy_encoding(col_vars), flat_df = TRUE)
    stopif(!is.null(subgroup) && !is.logical(subgroup), "'subgroup' should be logical.")
    
    check_sizes("'cro_fun'", cell_vars, row_vars, col_vars, weight, subgroup)
    
    cell_vars = make_labels_from_names(cell_vars)
    
    
    
    res = lapply(row_vars, function(each_row_var){
        all_col_vars = lapply(col_vars, function(each_col_var){
            dtable = elementary_cro_fun_df(cell_var = cell_vars,
                                           row_var = each_row_var, 
                                           col_var = each_col_var, 
                                           weight = weight,
                                           subgroup = subgroup,
                                           fun = fun
            )    
            row_var_lab = var_lab(dtable[["..row_var__"]])
            col_var_lab = var_lab(dtable[["..col_var__"]])
            ### make rectangular table  
            res = long_datatable_to_table(dtable, rows = c("..row_var__", "row_labels"), 
                                          columns = "..col_var__", 
                                          values = colnames(dtable) %d% c("..row_var__", "row_labels", "..col_var__")
            )
            format_table(res, 
                         row_var_lab = row_var_lab, 
                         col_var_lab = col_var_lab)  
        })
        Reduce(merge, all_col_vars)
    })
    
    res = do.call(add_rows, res)
    rownames(res) = NULL
    res
}


### compute statistics for single row_var and single col_var
elementary_cro_fun_df = function(cell_var, 
                                 col_var, 
                                 weight,
                                 fun,
                                 row_var,
                          subgroup
                          ){
    # to pass CRAN check
    ..weight__ = NULL
    
    ### calculate vector of valid cases

    valid = valid(col_var) & valid(row_var) & if_null(subgroup, TRUE)

    max_nrow = max(NROW(cell_var), NROW(col_var), NROW(row_var))
    
    ## if any of vars is zero-length then we made all vars zero-length
    min_nrow = min(NROW(cell_var), NROW(col_var), NROW(row_var))
    if(any(min_nrow==0)) max_nrow = 0
    
    ##### prepare weight #####
    if(!is.null(weight)){
        weight = set_negative_and_na_to_zero(weight)
        weight = recycle_if_single_row(weight, max_nrow)
        valid = valid & (weight>0)
        weight = weight[valid]
    }
    

    ### recycle variables of length 1

    cell_var = recycle_if_single_row(cell_var, max_nrow)
    col_var = recycle_if_single_row(col_var, max_nrow)
    row_var = recycle_if_single_row(row_var, max_nrow)
    
    ### drop non-valid cases 
    
    cell_var = universal_subset(cell_var, valid, drop = FALSE)
    col_var = universal_subset(col_var, valid)
    row_var = universal_subset(row_var, valid, drop = FALSE)

    ###################

    ### pack data.table #####
    if(is.data.frame(cell_var)){
        colnames(cell_var) = make_items_unique(colnames(cell_var))
    }
    if(is.null(weight)){
        raw_data = data.table(..row_var__ = row_var, ..col_var__ = col_var, cell_var)
    } else {
        raw_data = data.table(..row_var__ = row_var, ..col_var__ = col_var, ..weight__ = weight, cell_var)
    }

    # statistics
    by_string = "..row_var__,..col_var__"
    if(is.null(weight)){
        dtable = raw_data[ , fun(.SD), by = by_string]
    } else {
        dtable = raw_data[ , fun(.SD, weight = ..weight__), by = by_string, .SDcols = -"..weight__"]
    }
    dtable
}    

    

    
########
  
format_table = function(wide_datable, row_var_lab, col_var_lab){  
    # to pass CRAN check
    row_labels = NULL
    ..row_var__ = NULL

    wide_datable[ , row_labels  := as.character(row_labels)] 
    wide_datable[ , row_labels  := paste0(..row_var__, "|", row_labels)]  
    wide_datable[["..row_var__"]] = NULL
    
    wide_datable[, row_labels := paste0(row_var_lab, "|", row_labels)]
    colnames(wide_datable)[-1] = paste0(col_var_lab, "|", colnames(wide_datable)[-1]) 

    wide_datable[ , row_labels := remove_unnecessary_splitters(row_labels)] 
    wide_datable[ , row_labels := make_items_unique(row_labels)] 
    colnames(wide_datable) = remove_unnecessary_splitters(colnames(wide_datable)) 
    wide_datable = as.dtfrm(wide_datable)
    class(wide_datable) = union("etable", class(wide_datable))
    wide_datable
}

#######
    
make_function_for_cro_df = function(fun, ..., need_weight = TRUE){
    # to pass CRAN check
    row_labels = NULL
    
    force(fun)
    force(need_weight)
    if(need_weight){
        function(x, weight = weight){
            res = fun(x, ..., weight = weight)
            res = make_dataframe_with_row_labels(res)
            # we need convert to factor to keep order of row_labels
            as.list(res[, row_labels := fctr(row_labels, levels = unique(row_labels),
                                             prepend_var_lab = FALSE)])
        }
    } else {
        function(x){
            res = fun(x, ...)
            res = make_dataframe_with_row_labels(res)
            # we need convert to factor to keep order of row_labels
            as.list(res[, row_labels := fctr(row_labels, levels = unique(row_labels),
                                             prepend_var_lab = FALSE)])
        }        
    }
}

###############
make_function_for_cro = function(fun, ..., need_weight = TRUE){
    # to pass CRAN check
    row_labels = NULL
    force(fun)
    force(need_weight)
    if(need_weight){
        function(x, weight = weight){
            res = lapply(x, function(column) {
                varlab = var_lab(column)
                each_res = fun(unvr(column), ..., weight = weight)
                each_res = make_dataframe_with_row_labels(each_res)
                if(!is.null(varlab)){
                    each_res[["row_labels"]] = paste0(varlab, "|", each_res[["row_labels"]]) 
                }
                each_res
            })
            res = rbindlist(res, use.names = TRUE, fill = TRUE)
            # we need convert to factor to keep order of row_labels
            res[, row_labels := make_items_unique(row_labels)]
            as.list(res[, row_labels := fctr(row_labels, levels = unique(row_labels),
                                             prepend_var_lab = FALSE)])
        }
    } else {
        function(x){
            res = lapply(x, function(column) {
                varlab = var_lab(column)
                each_res = fun(unvr(column), ...)
                each_res = make_dataframe_with_row_labels(each_res)
                if(!is.null(varlab)){
                    each_res[["row_labels"]] = paste0(varlab, "|", each_res[["row_labels"]])
                }
                each_res
            })
            res = rbindlist(res, use.names = TRUE, fill = TRUE)
            # we need convert to factor to keep order of row_labels
            res[, row_labels := make_items_unique(row_labels)]
            as.list(res[, row_labels := fctr(row_labels, levels = unique(row_labels),
                                             prepend_var_lab = FALSE)])
        }        
    }
}

#############
make_dataframe_with_row_labels = function(res){
    if(is.table(res)){
        dm_names = dimnames(res)
        if(is.null(dm_names)){
            dm_names[[1]] = names(res)
        }
        new_df = matrix(NA, nrow= NROW(res), ncol = NCOL(res))
        new_df[] = res
        new_df = as.dtfrm(new_df)
        rownames(new_df) = NULL
        
        row_labels = dm_names[[1]]
        if(length(dm_names)>1){
            new_df = setNames(new_df, dm_names[[2]])
        } else {
            new_df = setNames(dtfrm(new_df), rep("|", NCOL(new_df)))
        }
        res = new_df
    } else {
        if(is.matrix(res) || is_list(res)) res = as.dtfrm(res)
        if(is.data.frame(res)) {
            if("row_labels" %in% colnames(res)){
                row_labels = res[["row_labels"]]    
                res[["row_labels"]] = NULL
            } else {
                row_labels = rownames(res)
                if(!is.null(row_labels) && length(row_labels)==1 && row_labels[1]==1){
                    row_labels = ""
                }
            }
        } else {
            row_labels = names(res)
            res = setNames(dtfrm(res), rep("|", NCOL(res)))
        } 
    }
    if(is.null(row_labels)){
        if(nrow(res)>1){
            row_labels = seq_len(nrow(res)) 
        } else {
            row_labels = rep("", nrow(res)) # for empty results   
        }
    } 
    row_labels = make_items_unique(as.character(row_labels))
    data.table(row_labels = row_labels, res)

}




#######

#' @export
#' @rdname cro_fun
cro_fun_df = function(cell_vars, 
                      col_vars = total(), 
                      row_vars = total(label = ""),
                      weight = NULL,
                      subgroup = NULL,
                      fun, 
                      ...){
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))

    cell_vars = test_for_null_and_make_list(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    fun = match.fun(fun)
    if(!is.null(weight)){
        stopif(!("weight" %in% names(formals(fun))),
               "`weight` is provided but `fun` doesn't have formal `weight` argument.")
    }
    fun = make_function_for_cro_df(fun, ..., need_weight = !is.null(weight))
    
    cell_vars = make_labels_from_names(cell_vars)
    cell_vars = flat_list(cell_vars, flat_df = FALSE)
    row_vars = flat_list(multiples_to_single_columns_with_dummy_encoding(row_vars), flat_df = TRUE)
    col_vars = flat_list(multiples_to_single_columns_with_dummy_encoding(col_vars), flat_df = TRUE)
    
    stopif(!is.null(subgroup) && !is.logical(subgroup), "'subgroup' should be logical.")
    check_sizes("'cro_fun_df'", cell_vars, row_vars, col_vars, weight, subgroup)
    
    res = lapply(row_vars, function(each_row_var){
        all_cell_vars = lapply(cell_vars, function(each_cell_var){
            all_col_vars = lapply(col_vars, function(each_col_var){
                dtable = elementary_cro_fun_df(cell_var = names2labels(each_cell_var),
                                      row_var = each_row_var, 
                                      col_var = each_col_var, 
                                      weight = weight,
                                      subgroup = subgroup,
                                      fun = fun
                )    
                row_var_lab = var_lab(dtable[["..row_var__"]])
                col_var_lab = var_lab(dtable[["..col_var__"]])
                ### make rectangular table  
                res = long_datatable_to_table(dtable, rows = c("..row_var__", "row_labels"), 
                                              columns = "..col_var__", 
                                              values = colnames(dtable) %d% c("..row_var__", "row_labels", "..col_var__")
                )
                format_table(res, 
                             row_var_lab = row_var_lab, 
                             col_var_lab = col_var_lab)
            })
            Reduce(merge, all_col_vars)
        })
        do.call(add_rows, all_cell_vars) 
        
    })
    res = do.call(add_rows, res)
    rownames(res) = NULL
    res
}

######################################################

#' @export
#' @rdname cro_fun
cro_mean = function(cell_vars, 
                    col_vars = total(), 
                    row_vars = total(label = ""),
                    weight = NULL,
                    subgroup = NULL
){
    
    fun = function(x, weight = NULL){
        res = vapply(x, FUN = w_mean, FUN.VALUE = numeric(1), weight = weight, USE.NAMES = FALSE)
        list(row_labels = names(x), "|" = res)
    }
    
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_dataframe(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    cro_fun_df(cell_vars = cell_vars, 
               col_vars = col_vars, 
               row_vars = row_vars, 
               weight = weight,
               subgroup = subgroup,
               fun = fun
    )
}

#' @export
#' @rdname cro_fun
cro_sum = function(cell_vars, 
                   col_vars = total(), 
                   row_vars = total(label = ""),
                   weight = NULL,
                   subgroup = NULL
){
    fun = function(x, weight = NULL){
        res = vapply(x, FUN = w_sum, FUN.VALUE = numeric(1), weight = weight, USE.NAMES = FALSE)
        list(row_labels = names(x), "|" = res)
    }
    
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_dataframe(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    cro_fun_df(cell_vars = cell_vars, 
               col_vars = col_vars, 
               row_vars = row_vars, 
               weight = weight,
               subgroup = subgroup,
               fun = fun
    )
}

#' @export
#' @rdname cro_fun
cro_median = function(cell_vars, 
                      col_vars = total(), 
                      row_vars = total(label = ""),
                      weight = NULL,
                      subgroup = NULL
){
    fun = function(x, weight = NULL){
        res = vapply(x, FUN = w_median, FUN.VALUE = numeric(1), weight = weight, USE.NAMES = FALSE)
        list(row_labels = names(x), "|" = res)
    }
    
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_dataframe(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    cro_fun_df(cell_vars = cell_vars, 
               col_vars = col_vars, 
               row_vars = row_vars, 
               weight = weight,
               subgroup = subgroup,
               fun = fun
    )
}


###############################################
###############################################
###############################################

#' @export
#' @rdname cro_fun
cro_pearson = function(cell_vars, 
                         col_vars = total(), 
                         row_vars = total(label = ""),
                         weight = NULL,
                         subgroup = NULL
){
    fun = function(x, weight = NULL){
        w_pearson(x, weight = weight)[ , 1]
    }    
    
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_list(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    cro_fun_df(cell_vars = cell_vars, 
               col_vars = col_vars, 
               row_vars = row_vars, 
               weight = weight,
               subgroup = subgroup,
               fun = fun
    )
}


#' @export
#' @rdname cro_fun
cro_spearman = function(cell_vars, 
                           col_vars = total(), 
                           row_vars = total(label = ""),
                           weight = NULL,
                           subgroup = NULL
){
    fun = function(x, weight = NULL){
        w_spearman(x, weight = weight)[ , 1]
    }    
    
    str_cell_vars = deparse(substitute(cell_vars))
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    
    cell_vars = test_for_null_and_make_list(cell_vars, str_cell_vars)
    row_vars = test_for_null_and_make_list(row_vars, str_row_vars)
    col_vars = test_for_null_and_make_list(col_vars, str_col_vars)
    
    cro_fun_df(cell_vars = cell_vars, 
               col_vars = col_vars, 
               row_vars = row_vars, 
               weight = weight,
               subgroup = subgroup,
               fun = fun
    )
}
    



#' @export
#' @rdname cro_fun
combine_functions = function(..., method = c){
    method = match.fun(method)
    possible_names = unlist(lapply(as.list(substitute(list(...)))[-1], deparse))
    args = list(...)
    arg_names =names(args)
    if(is.null(arg_names)) {
        names(args) = possible_names
    } else {
        names(args)[arg_names==""] = possible_names[arg_names==""]
    }  
    function(x, weight = NULL){
        if(!is.null(weight)){
            for(each in seq_along(args)){
                stopif(!("weight" %in% names(formals(args[[each]]))),
                       paste0("`weight` is provided but function`", names(args)[each],
                              "` doesn't have formal `weight` argument."))
            }    
        }
        res = lapply(args, function(f) f(x))
        do.call(method, res)
    }
}

