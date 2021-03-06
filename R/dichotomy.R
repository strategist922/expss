#' Convert variable (possibly multiple choice question) to data.frame/matrix of dummy variables.
#' 
#' This function converts variable/multiple response
#' variable (vector/matrix/data.frame) with category encoding into
#' data.frame/matrix with dichotomy encoding (0/1) suited for most statistical
#' analysis, e. g. clustering, factor analysis, linear regression and so on.
#' \itemize{ 
#' \item{\code{as.dichotomy}}{ returns data.frame of class 'dichotomy' with 0, 1
#' and possibly NA.}
#' \item{\code{dummy}}{ returns matrix of class 'dichotomy' with 0, 1 and possibly NA.}
#' \item{\code{dummy1}}{ drops last column in dichotomy matrix. It is useful in many cases
#' because any column of such matrix usually is linear combinations of other columns.}
#' }
#' @param x vector/factor/matrix/data.frame.
#' @param prefix character. By default "v".
#' @param keep_unused Logical. Should we create columns for unused value
#'   labels/factor levels? FALSE by default.
#' @param use_na Logical. Should we use NA for rows with all NA or use 0's
#'   instead. TRUE by default.
#' @param keep_values Numeric/character. Values that should be kept. By default
#'   all values will be kept.
#' @param keep_labels Numeric/character. Labels/levels that should be kept. By
#'   default all labels/levels will be kept.
#' @param drop_values Numeric/character. Values that should be dropped. By default
#'   all values will be kept. Ignored if keep_values/keep_labels are provided.
#' @param drop_labels Numeric/character. Labels/levels that should be dropped. By
#'   default all labels/levels will be kept. Ignored if keep_values/keep_labels are provided.
#' @return  \code{as.dichotomy} returns data.frame of class \code{dichotomy} 
#'   with 0,1. Columns of this data.frame have variable labels according to
#'   value labels of original data. If label doesn't exist for particular value
#'   then this value will be used as variable label. \code{dummy} returns matrix
#'   of class \code{dichotomy}. Column names of this matrix are value labels of
#'   original data.
#' @seealso \code{\link{as.category}} for reverse conversion, \link{mrset},
#'   \link{mdset} for usage multiple-response variables with tables.
#' @examples
#' # toy example
#' # brands - multiple response question
#' # Which brands do you use during last three months? 
#' set.seed(123)
#' brands = as.dtfrm(t(replicate(20,sample(c(1:5,NA),4,replace = FALSE))))
#' # score - evaluation of tested product
#' score = sample(-1:1,20,replace = TRUE)
#' var_lab(brands) = "Used brands"
#' val_lab(brands) = autonum("
#'                               Brand A
#'                               Brand B
#'                               Brand C
#'                               Brand D
#'                               Brand E
#'                               ")
#' 
#' var_lab(score) = "Evaluation of tested brand"
#' val_lab(score) = make_labels("
#'                              -1 Dislike it
#'                               0 So-so
#'                               1 Like it    
#'                              ")
#' 
#' cro_cpct(as.dichotomy(brands), score)
#' # the same as
#' cro_cpct(mrset(brands), score)
#' 
#' # customer segmentation by used brands
#' kmeans(dummy(brands), 3)
#' 
#' # model of influence of used brands on evaluation of tested product 
#' summary(lm(score ~ dummy(brands)))
#' 
#' # prefixed data.frame 
#' as.dichotomy(brands, prefix = "brand_")
#' 
#' @export
as.dichotomy = function(x, prefix = "v", keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                        keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    UseMethod("as.dichotomy")
}


#' @export
as.dichotomy.default = function(x, prefix = "v", keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                                keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    if(!is.labelled(x)) x = as.labelled(x)
    vallab = get_values_for_dichotomizing(x = x,
                                          keep_unused = keep_unused,
                                          keep_values = keep_values, 
                                          keep_labels = keep_labels, 
                                          drop_values = drop_values, 
                                          drop_labels = drop_labels)
    
    not_nas = !is.na(x)
    res = vapply(vallab,
                 FUN = function(value) as.numeric((x == value) & not_nas),
                 FUN.VALUE = numeric(length(x)),
                 USE.NAMES = FALSE
    )
    if(length(res) > 0){
        res = as.matrix(res)
    } else {
        res = matrix(NA, nrow = NROW(x), ncol = 0)
    }
    if(use_na && NCOL(res)>0){
        nas = is.na(x)
        res[nas,] = NA
    }
    res = as.dtfrm(res)
    if(NCOL(res)>0){
        colnames(res) = paste0(prefix, vallab)
        for (each in seq_along(res)){
            var_lab(res[[each]]) = names(vallab)[each]
        }
    } else {
        if(NROW(res)>0) {
            res[["NA"]] = NA
        } else {
            res[["NA"]] = logical(0)
        }   
    }


    class(res) = union("dichotomy", setdiff(class(res), "category")) 
    res  
}

#' @export
as.dichotomy.data.frame = function(x, prefix = "v", keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                                keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    vallab = get_values_for_dichotomizing(x = x,
                                          keep_unused = keep_unused,
                                          keep_values = keep_values, 
                                          keep_labels = keep_labels, 
                                          drop_values = drop_values, 
                                          drop_labels = drop_labels)

    res = matrix(FALSE, nrow = NROW(x), ncol = length(vallab))
    x = as.matrix(x)
    for (i in seq_along(vallab)) res[ , i] = res[ , i] | (rowSums(x == vallab[i], na.rm = TRUE)>0)
    if(use_na & NCOL(x)>0){
        nas = rowSums(!is.na(x))==0
        res[nas,] = NA
    }
    res[] = as.numeric(res)
    res = as.dtfrm(res)
    if(NCOL(res)>0){
        colnames(res) = paste0(prefix, vallab)
    }
    for (each in seq_along(res)){
        var_lab(res[[each]]) = names(vallab)[each]
    }
    if(ncol(res) == 0){
        if(NROW(res)>0) {
            res[["NA"]] = NA
        } else {
            res[["NA"]] = logical(0)
        }    
    } 
    class(res) = union("dichotomy", setdiff(class(res), "category")) 
    res  
}

#' @export
as.dichotomy.matrix = as.dichotomy.data.frame


########################################

#' @export
#' @rdname as.dichotomy
dummy = function(x, keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                     keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    UseMethod("dummy")
    
}

#' @export
dummy.default = function(x, keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                 keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    if(!is.labelled(x)) x = as.labelled(x)
    vallab = get_values_for_dichotomizing(x = x,
                                          keep_unused = keep_unused,
                                          keep_values = keep_values, 
                                          keep_labels = keep_labels, 
                                          drop_values = drop_values, 
                                          drop_labels = drop_labels)
    

    not_nas = !is.na(x)
    res = vapply(vallab,
                 FUN = function(value) as.numeric((x == value) & not_nas),
                 FUN.VALUE = numeric(length(x)),
                 USE.NAMES = FALSE
    )
    if(length(res) > 0){
        res = as.matrix(res)
    } else {
        res = matrix(NA, nrow = NROW(x), ncol = 0)
    }
    if(use_na){
        nas = is.na(x)
        res[nas,] = NA
    }
    if(NCOL(res)>0){
        colnames(res) = names(vallab)
    } else {
        if(NROW(res)>0){
            res = cbind(res, NA)
            colnames(res) = "NA"
        }
    }
    class(res) = union("dichotomy", setdiff(class(res), "category")) 
    res  
}

#' @export
dummy.data.frame = function(x, keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                                   keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    vallab = get_values_for_dichotomizing(x = x,
                                          keep_unused = keep_unused,
                                          keep_values = keep_values, 
                                          keep_labels = keep_labels, 
                                          drop_values = drop_values, 
                                          drop_labels = drop_labels)
    
    res = matrix(FALSE, nrow = NROW(x), ncol = length(vallab))
    x = as.matrix(x)
    for (i in seq_along(vallab)) res[ , i] = res[ , i] | (rowSums(x == vallab[i], na.rm = TRUE)>0)
    if(use_na && NCOL(x)>0){
        nas = rowSums(!is.na(x))==0
        res[nas,] = NA
    }
    res[] = as.numeric(res)
    if(NCOL(res)>0){
        colnames(res) = names(vallab)
    } else {
        if(NROW(res)>0){
            res = cbind(res, NA)
            colnames(res) = "NA"
        }
    }
    class(res) = union("dichotomy", setdiff(class(res), "category")) 
    res  

}


#' @export
dummy.matrix = dummy.data.frame

#' @export
#' @rdname as.dichotomy
dummy1 = function(x, keep_unused = FALSE, use_na = TRUE, keep_values = NULL,
                  keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    res = dummy(x,
                keep_unused = keep_unused,
                use_na = use_na,
                keep_values = keep_values, 
                keep_labels = keep_labels, 
                drop_values = drop_values, 
                drop_labels = drop_labels)
    if (NCOL(res)>1){
        res = res[, -ncol(res), drop = FALSE]
    }
    class(res) = union("dichotomy", setdiff(class(res), "category")) 
    res
}

#' @export
#' @rdname as.dichotomy
is.dichotomy = function(x){
    inherits(x, "dichotomy")
}



# returns values+labels that will be used during dichotomizing
get_values_for_dichotomizing = function(x, keep_unused = FALSE, keep_values = NULL,
                            keep_labels = NULL, drop_values = NULL, drop_labels = NULL){
    vallab = val_lab(x)
    varlab = var_lab(x)
    x = unlab(x)
    x = c(x, recursive = TRUE)
    if(is.null(x)) {
        uniqs = numeric(0)
    }  else {  
        uniqs=sort(unique(x))
    }
    if(!is.null(keep_values) && keep_unused){
        uniqs = sort(union(uniqs, keep_values))
    }
    if(!is.null(keep_labels) && keep_unused){
            stopif(!all(keep_labels %in% names(vallab)),"keep_unused = TRUE but some values in 'keep_labels'",
                   " doesn't exist in value labels, e. g. '", setdiff(keep_labels, names(vallab))[1],"'")
    }
    if (length(uniqs)>0) uniqs = uniqs[!is.na(uniqs)]
    vallab = labelled_and_unlabelled(uniqs, vallab)
    if (!keep_unused) {
        vallab = vallab[vallab %in% uniqs]        
    } 
    if(!is.null(keep_values)){
            vallab = vallab[vallab %in% keep_values]
    } 
    if(!is.null(keep_labels)){
            vallab = vallab[keep_labels]
    }
    if(is.null(keep_values) && is.null(keep_labels)){
        if(!is.null(drop_values)){
            vallab = vallab[!(vallab %in% drop_values)]
        }
        if(!is.null(drop_labels)){
            vallab = vallab[setdiff(names(vallab), drop_labels)]
        }
    }
    if (!is.null(varlab) && (varlab!="")) {
        names(vallab) = paste(varlab, names(vallab), sep = LABELS_SEP) 
    }    

    vallab    
}







