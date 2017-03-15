#' Cross tabulation with support of labels, weights and multiple response variables.
#' 
#' \itemize{
#' \item{\code{cro}}{ returns data.frame with counts (possibly weighted) with column and
#' row totals.}
#' \item{\code{cro_pct}, \code{cro_cpct}, \code{cro_rpct}}{ return data.frame with 
#' table/column/row percent with column and row totals. There are always 
#' weighted counts instead of margin with 100\%. Empty labels/factor levels are 
#' removed from results of these functions. Base for multiple response (x is 
#' data.frame) percent is number of valid cases (not sum of responses) so sum of
#' percent may be greater than 100. Case is considered as valid if it has at
#' least one non-NA value.}
#' \item{\code{cro_mean}, \code{cro_sum}, \code{cro_median}}{ return data.frame with 
#' mean/sum/median. Empty labels/factor levels are 
#' removed from results of these functions. NA's are always omitted.}
#' \item{\code{cro_fun}, \code{cro_fun_df}}{ return data.frame with custom 
#' summary statistics defined by 'fun' argument. Empty labels/factor levels in 
#' predictor are removed from results of these functions. NA's treatment depends
#' on your 'fun' behavior. To use weight you should have 'weight' argument in 
#' 'fun' and some logic for its proccessing inside.\code{cro_fun} applies 'fun'
#' on each column in 'x' separately, \code{cro_fun_df} gives to 'fun' x as a
#' whole data.frame. So \code{cro_fun(iris[, -5], iris$Species, fun = mean)}
#' gives the same result as \code{cro_fun_df(iris[, -5], iris$Species, fun =
#' colMeans)}. For \code{cro_fun_df} names of 'x' will converted to labels if
#' they are available before 'fun' is applied. You should take care to return
#' from 'fun' rectangular object with appropriate row/column names - they will
#' be used in final result as labels.}
#' }
#' 
#' @param x vector/data.frame. data.frames are considered as multiple response
#'   variables.
#' @param row_vars vector. By now multiple-response predictor is not supported.
#' @param col_vars vector. By now multiple-response predictor is not supported.
#' @param weight numeric vector. Optional case weights. NA's and negative weights
#'   treated as zero weights.
#' @param total_row_position Position ot total row in the resulting table. Can
#'   be one of "below", "above", "none".
#' @param weighted_total  By default it is "unweighted". Can be "unweighted" or/and "weighted". You can show weighted total/unweighted total or both.
#' @param total_row_title By default "#Total". You can provide two titles - for weighted and unqeighted totals.
#' @param fun custom summary function. It should always return
#'   scalar/vector/matrix of the same size.
#' @param ... further arguments for \code{fun}   
#'
#' @return object of class 'etable'. Basically it's a data.frame but class
#'   is needed for custom methods.
#'
#' @examples
#' data(mtcars)
#' mtcars = apply_labels(mtcars,
#'                       mpg = "Miles/(US) gallon|Mean",
#'                       cyl = "Number of cylinders",
#'                       disp = "Displacement (cu.in.)|Mean",
#'                       hp = "Gross horsepower|Mean",
#'                       drat = "Rear axle ratio",
#'                       wt = "Weight (lb/1000)",
#'                       qsec = "1/4 mile time|Mean",
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
#' calculate(mtcars, cro(am, vs))
#' 
#' # multiple banners
#' calculate(mtcars, cro(cyl, list("#Total", vs, am, carb)))
#' 
#' # column percent
#' calculate(mtcars, cro_cpct(cyl, list("#Total", vs, am, carb)))
#' 
#' # nested banner
#' calculate(mtcars, cro(cyl, list("#Total", vs %nest% am, carb)))
#' 
#' # stacked variables
#' calculate(mtcars, cro(list(cyl, carb), list("#Total", vs %nest% am)))
#' 
#' # nested variables
#' calculate(mtcars, cro(am %nest% cyl, list("#Total", vs, carb)))
#' 
#' # multiple-choice variable
#' # brands - multiple response question
#' # Which brands do you use during last three months? 
#' set.seed(123)
#' brands = data.frame(t(replicate(20,sample(c(1:5,NA),4,replace = FALSE))))
#' # score - evaluation of tested product
#' score = sample(-1:1,20,replace = TRUE)
#' var_lab(brands) = "Used brands"
#' val_lab(brands) = make_labels("
#'                               1 Brand A
#'                               2 Brand B
#'                               3 Brand C
#'                               4 Brand D
#'                               5 Brand E
#'                               ")
#' 
#' var_lab(score) = "Evaluation of tested brand"
#' val_lab(score) = make_labels("
#'                              -1 Dislike it
#'                              0 So-so
#'                              1 Like it    
#'                              ")
#' 
#' cro(mrset(brands), list("#Total", score))
#' cro_cpct(mrset(brands), list("#Total", score))
#' 
#' # 'cro_mean'
#' 
#' data(iris)
#' cro_mean(iris[, -5], iris$Species)
#' 
#' # 'cro_fun'
#' 
#' data(mtcars)
#' mtcars = modify(mtcars,{
#'     var_lab(vs) = "Engine"
#'     val_lab(vs) = c("V-engine" = 0, 
#'                     "Straight engine" = 1) 
#'     var_lab(hp) = "Gross horsepower"
#'     var_lab(mpg) = "Miles/(US) gallon"
#' })
#' 
#' # Label for 'disp' forgotten intentionally
#' with(mtcars, cro_fun(data.frame(hp, mpg, disp), vs, summary))
#' 
#' # or, the same with transposed summary
#' with(mtcars, cro_fun(data.frame(hp, mpg, disp), vs, function(x) t(summary(x))))
#' 
#' # very artificial example
#' a = c(1,1,1, 1, 1)
#' b = c(0, 1, 2, 2, NA)
#' weight = c(0, 0, 1, 1, 1)
#' cro_fun(b, a, weight = weight, 
#'      fun = function(x, weight, na.rm){
#'                  weighted.mean(x, w = weight, na.rm = na.rm)
#'              }, 
#'      na.rm = TRUE)
#' 
#' 
#' # comparison 'cro_fun' and 'cro_fun_df'
#' 
#' data(iris)
#' cro_fun(iris[, -5], iris$Species, fun = mean)
#' # same result
#' cro_fun_df(iris[, -5], iris$Species, fun = colMeans)  
#' 
#' # usage for 'cro_fun_df' which is not possible for 'cro_fun'
#' # calculate correlations of variables with Sepal.Length inside each group
#' cro_fun_df(iris[,-5], iris$Species, fun = function(x) cor(x)[,1])
#' 
#' # or, pairwise correlations inside groups
#' cro_fun_df(iris[,-5], iris$Species, fun = cor)
#' @export
cro = function(row_vars, 
               col_vars = total(), 
               weight = NULL, 
               subgroup = NULL,
               total_title = "#Total",
               total = "unweighted",
               total_row_position = c("below", "above", "none")
               ){
    
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    stopif(is.null(row_vars), 
           paste0("'", str_row_vars,"' is NULL. Possibly variable doesn't exist."))
    stopif(is.null(col_vars), 
           paste0("'", str_col_vars,"' is NULL. Possibly variable doesn't exist."))
    if(!is_list(row_vars)){
        row_vars = add_missing_var_lab(row_vars, str_row_vars)
        row_vars = list(row_vars)
    }
    if(!is_list(col_vars)){
        col_vars = add_missing_var_lab(col_vars, str_col_vars)
        col_vars = list(col_vars)
    }
    multi_cro(row_vars = row_vars, 
              col_vars = col_vars, 
              weight = weight,
              total_title = total_title,
              total = total,
              total_row_position = total_row_position,
              subgroup = subgroup,
              prepend_var_lab = TRUE,
              stat_type = "count"
    )    
}




#' @export
#' @rdname cro
cro_cpct = function(row_vars, 
                    col_vars = total(), 
                    weight = NULL, 
                    subgroup = NULL,
                    total_title = "#Total",
                    total = "unweighted",
                    total_row_position = c("below", "above", "none")
                    ){
    
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    stopif(is.null(row_vars), 
           paste0("'", str_row_vars,"' is NULL. Possibly variable doesn't exist."))
    stopif(is.null(col_vars), 
           paste0("'", str_col_vars,"' is NULL. Possibly variable doesn't exist."))
    if(!is_list(row_vars)){
        row_vars = add_missing_var_lab(row_vars, str_row_vars)
        row_vars = list(row_vars)
    }
    if(!is_list(col_vars)){
        col_vars = add_missing_var_lab(col_vars, str_col_vars)
        col_vars = list(col_vars)
    }
    multi_cro(row_vars = row_vars, 
              col_vars = col_vars, 
              weight = weight,
              total_title = total_title,
              total = total,
              total_row_position = total_row_position,
              subgroup = subgroup,
              prepend_var_lab = TRUE,
              stat_type = "cpct"
    )    
}

#' @export
#' @rdname cro
cro_rpct = function(row_vars, 
                    col_vars = total(), 
                    weight = NULL, 
                    subgroup = NULL,
                    total_title = "#Total",
                    total = "unweighted",
                    total_row_position = c("below", "above", "none")
                    ){
    
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    stopif(is.null(row_vars), 
           paste0("'", str_row_vars,"' is NULL. Possibly variable doesn't exist."))
    stopif(is.null(col_vars), 
           paste0("'", str_col_vars,"' is NULL. Possibly variable doesn't exist."))
    if(!is_list(row_vars)){
        row_vars = add_missing_var_lab(row_vars, str_row_vars)
        row_vars = list(row_vars)
    }
    if(!is_list(col_vars)){
        col_vars = add_missing_var_lab(col_vars, str_col_vars)
        col_vars = list(col_vars)
    }
    multi_cro(row_vars = row_vars, 
              col_vars = col_vars, 
              weight = weight,
              total_title = total_title,
              total = total,
              total_row_position = total_row_position,
              subgroup = subgroup,
              prepend_var_lab = TRUE,
              stat_type = "rpct"
    )    
}


#' @export
#' @rdname cro
cro_tpct = function(row_vars, 
                    col_vars = total(), 
                    weight = NULL, 
                    subgroup = NULL,
                    total_title = "#Total",
                    total = "unweighted",
                    total_row_position = c("below", "above", "none")
                    ){
    
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    stopif(is.null(row_vars), 
           paste0("'", str_row_vars,"' is NULL. Possibly variable doesn't exist."))
    stopif(is.null(col_vars), 
           paste0("'", str_col_vars,"' is NULL. Possibly variable doesn't exist."))
    if(!is_list(row_vars)){
        row_vars = add_missing_var_lab(row_vars, str_row_vars)
        row_vars = list(row_vars)
    }
    if(!is_list(col_vars)){
        col_vars = add_missing_var_lab(col_vars, str_col_vars)
        col_vars = list(col_vars)
    }
    multi_cro(row_vars = row_vars, 
              col_vars = col_vars, 
              weight = weight,
              total_title = total_title,
              total = total,
              total_row_position = total_row_position,
              subgroup = subgroup,
              prepend_var_lab = TRUE,
              stat_type = "tpct"
    )    
}

#' @export
#' @rdname cro
cro_cpct_responses = function(row_vars, 
                              col_vars = total(), 
                              weight = NULL, 
                              subgroup = NULL,
                              total_title = "#Total",
                              total = "unweighted",
                              total_row_position = c("below", "above", "none")
                              ){
    
    str_row_vars = deparse(substitute(row_vars))
    str_col_vars = deparse(substitute(col_vars))
    stopif(is.null(row_vars), 
           paste0("'", str_row_vars,"' is NULL. Possibly variable doesn't exist."))
    stopif(is.null(col_vars), 
           paste0("'", str_col_vars,"' is NULL. Possibly variable doesn't exist."))
    if(!is_list(row_vars)){
        row_vars = add_missing_var_lab(row_vars, str_row_vars)
        row_vars = list(row_vars)
    }
    if(!is_list(col_vars)){
        col_vars = add_missing_var_lab(col_vars, str_col_vars)
        col_vars = list(col_vars)
    }
    multi_cro(row_vars = row_vars, 
              col_vars = col_vars, 
              weight = weight,
              total_title = total_title,
              total = total,
              total_row_position = total_row_position,
              subgroup = subgroup,
              prepend_var_lab = TRUE,
              stat_type = "cpct_responses"
    )    
}


### compute statistics for single row_var and single col_var
elementary_cro = function(row_var, col_var, weight = NULL, 
                          total_title,
                          total,
                          total_row_position = c("below", "above", "none"),
                          prepend_var_lab,
                          subgroup,
                          stat_type = c("count", "cpct", "cpct_responses", "rpct", "tpct")
                          ){
    
    ### preparations
    total_row_position = match.arg(total_row_position)
    total = match.arg(total, c("unweighted", "weighted"), several.ok = TRUE)
    stat_type = match.arg(stat_type)
    max_nrow = max(NROW(row_var), NROW(col_var))
    
    weight = if_null(weight, 1)
    weight = set_negative_and_na_to_zero(weight)
    if(length(weight)==1) weight = rep(weight, max_nrow)
    
    valid = valid(row_var) & valid(col_var) & (weight>0)
    
    if(!is.null(subgroup)) {
        valid = valid & subgroup
    }
    
    weight = weight[valid]
    
    if(length(col_var)==1) col_var = rep(col_var, max_nrow)
    col_var = col_var[valid]
    
    if(NROW(row_var)==1){
        if(is.matrix(row_var) || is.data.frame(row_var)){
            row_var =  row_var[rep(1, max_nrow), ]
        } else {
            row_var = rep(row_var, max_nrow)
        }
    }
    
    row_var = convert_multicolumn_object_to_vector(row_var)
    row_var = row_var[valid]

    row_var_lab = var_lab(row_var)
    col_var_lab = var_lab(col_var)
    
    raw_data = data.table(row_var = row_var, col_var = col_var, weight = weight)
    raw_data = raw_data[!is.na(row_var), ]
    
    # statistics
    
    dtable = raw_data[, list(value = sum(weight, na.rm = TRUE)), by = "col_var,row_var"]
    
    dtotal = data.table(col_var = col_var, weight = weight)
    dtotal = dtotal[, list(weighted_total = sum(weight, na.rm = TRUE), 
                               total = .N), by = "col_var"]

    if(stat_type=="cpct" || stat_type=="cpct_responses"){
        dtable = dtotal[dtable, on = "col_var", nomatch = NA]
        dtable[, value := value/weighted_total*100]
        if(stat_type == "cpct_responses"){
            dtable[, value := value/sum(value, na.rm = TRUE)*100, by = "col_var"]
        }
    }
    if(stat_type=="tpct"){
        dtable = dtotal[dtable, on = "col_var", nomatch = NA]
        dtable[, value := value/sum(weight, na.rm = TRUE)*100]
    }
    if(stat_type=="rpct"){
        row_total = raw_data[, list(weighted_total = sum(weight, na.rm = TRUE)), by = "row_var"]
        dtable = row_total[dtable, on = "row_var", nomatch = NA]
        dtable[, value := value/weighted_total*100]
    }

    ### make rectangular table  
    res = long_datatable_to_table(dtable, rows = "row_var", columns = "col_var", value = "value")
    colnames(res)[1] = "row_labels"
    
    if(total_row_position!="none"){
        res = add_total_to_table(
            res = res, 
            dtotal = dtotal,
            total_row_position = total_row_position,
            total = total,
            total_title = total_title
        )    
    }    

    rownames(res) = NULL
    
    if(prepend_var_lab){
        res[[1]] = paste0(row_var_lab, "|", res[[1]])
        colnames(res)[-1] = paste0(col_var_lab, "|", colnames(res)[-1]) 
    }
    
    
    res[[1]] = remove_unnecessary_splitters(res[[1]]) 
    res[[1]] = make_items_unique(res[[1]])
    colnames(res) = remove_unnecessary_splitters(colnames(res)) 
    class(res) = union("etable", class(res))
    res
}

###########################

add_total_to_table = function(res, dtotal, total_row_position, total, total_title){
    if(length(total)==0) total = "unweighted"
    if(length(total_title) == 0) total_title = "#Total"
    if(length(total_title) < length(total)) total_title = rep(total_title, length(total))
   
    total =  c("unweighted" = "total", "weighted" = "weighted_total")[total]
    total_row = lapply(seq_along(total), function(item){
        dtotal[, title := ""]  
        row = long_datatable_to_table(dtotal, 
                                rows = "title", 
                                columns = "col_var", 
                                value = total[item])
        colnames(row)[1] = "row_labels"
        row[[1]] = add_first_symbol_to_total_title(total_title[item])
        row
    })
    total_row = do.call(add_rows, total_row)
    if(total_row_position=="above"){
        res = add_rows(total_row, res)
    } else {
        res = add_rows(res, total_row)
    }
    res
}

#################################

multi_cro = function(row_vars, 
               col_vars, 
               weight, 
               subgroup,
               total_title,
               total,
               total_row_position = c("below", "above", "none"),
               prepend_var_lab,
               stat_type){
    row_vars = flat_list(dichotomy_to_category_encoding(row_vars), flat_df = FALSE)
    col_vars = flat_list(multiples_to_single_columns_with_dummy_encoding(col_vars), flat_df = TRUE)
    stopif(!is.null(subgroup) && !is.logical(subgroup), "'subgroup' should be logical.")
    check_sizes("'cro'", row_vars, col_vars, weight, subgroup)
    res = lapply(row_vars, function(each_row_var){
        all_col_vars = lapply(col_vars, function(each_col_var){
            elementary_cro(row_var = each_row_var, 
                           col_var = each_col_var, 
                           weight = weight,
                           total_title = total_title,
                           total = total,
                           total_row_position = total_row_position,
                           subgroup = subgroup,
                           prepend_var_lab = prepend_var_lab,
                           stat_type = stat_type
            )    
        })
        Reduce(merge, all_col_vars)
        
    })
    res = do.call(add_rows, res)
    res
}

######################################################


