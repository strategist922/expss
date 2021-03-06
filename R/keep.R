#' Keep or drop elements by name/criteria in data.frame/matrix/list/vector
#' 
#' \code{keep} selects variables/elements from data.frame by their names or by 
#' criteria (see \link{criteria}). \code{except} drops  variables/elements from 
#' data.frame by their names or by criteria. There is no non-standard evaluation
#' in these functions by design so use quotes for names of your variables or use
#' \link{qc}. The only exception with non-standard evaluation is \code{\%to\%}. 
#' See example. Character arguments will be expanded as with \link{subst}. 
#' \code{a`1:2`} will be translated to \code{'a1', 'a2'}. 
#' \code{\%keep\%}/\code{\%except\%} are infix versions of these functions.
#' Methods for list will apply \code{keep}/\code{except} to each element of
#' the list separately. \code{.keep}/\code{.except} are versions which works
#' with \link{default_dataset}.
#'
#' @param data data.frame/matrix/list/vector
#' @param ... column names/element names of type character or criteria/logical functions
#' @param variables column names/element names of type character or criteria/logical functions
#'
#' @return object of the same type as \code{data}
#' @export
#'
#' @examples
#' keep(iris, "Sepal.Length", "Sepal.Width")  
#' keep(iris, qc(Sepal.Length, Sepal.Width)) # same result with non-standard eval 
#' except(iris, "Species")
#' 
#' keep(iris, "Species", other) # move 'Species' to the first position
#' keep(iris, to("Petal.Width")) # keep all columns up to 'Species'
#' 
#' except(iris, perl("^Petal")) # remove columns which names start with 'Petal'
#' 
#' except(iris, items(5)) # remove fifth column
#' 
#' keep(airquality, from("Ozone") & to("Wind")) # keep columns from 'Ozone' to 'Wind'
#' 
#' # the same examples with infix operators
#' 
#' iris %keep% c("Sepal.Length", "Sepal.Width") 
#' iris %keep% qc(Sepal.Length, Sepal.Width) # same result with non-standard eval
#' iris %except% "Species"
#' 
#' iris %keep% c("Species", other) # move 'Species' to the first position
#' iris %keep% to("Petal.Width")   # keep all columns except 'Species'
#' 
#' iris %except% perl("^Petal")    # remove columns which names start with 'Petal'
#' 
#' airquality %keep% (from("Ozone") & to("Wind")) # keep columns from 'Ozone' to 'Wind'
#'     
#' keep(airquality, Ozone %to% Wind) # the same result 
#' airquality %keep% (Ozone %to% Wind) # the same result 
#' 
#' # character expansion
#' dfs = data.frame(
#'      a = 10 %r% 5,
#'      b_1 = 11 %r% 5,
#'      b_2 = 12 %r% 5,
#'      b_3 = 12 %r% 5,
#'      b_4 = 14 %r% 5,
#'      b_5 = 15 %r% 5 
#'  )
#'  i = 1:5
#'  keep(dfs, "b_`i`")
#'  keep(dfs, b_1 %to% b_5) # the same result
keep = function(data, ...){
    UseMethod("keep")
}

# # @export
# keep.default = function(data, ...){
#     vars = names(data)
#     args = substitute(list(...))
#     args = substitute_symbols(args,
#                               list("%to%" = ".internal_to_")
#     )
#     args = eval(args)
#     new_vars = keep_helper(vars, args)
#     res = data[new_vars]
#     names(res) = vars[new_vars] # prevents names correction
#     res
# }

#' @export
keep.list = function(data, ...){
    for(each in seq_along(data)){
        data[[each]] = eval(
            substitute(keep(data[[each]], ...)), 
            envir = parent.frame(),
            enclos = baseenv()
        )
    }
    data
}

#' @export
keep.data.frame = function(data, ...){
    vars = colnames(data)
    args = substitute(list(...))
    args = substitute_symbols(args,
                              list("%to%" = ".internal_to_")
                              )
    args = eval(args, envir = parent.frame(),
                enclos = baseenv())
    new_vars = keep_helper(vars, args)
    if(is.data.table(data)){
        res = data[ , new_vars, with = FALSE]
    } else {
        res = data[ , new_vars, drop = FALSE]
        colnames(res) = vars[new_vars] # prevents names correction    
    }
   
    res
}

#' @export
keep.matrix = function(data, ...){
    vars = colnames(data)
    args = substitute(list(...))
    args = substitute_symbols(args,
                              list("%to%" = ".internal_to_")
    )
    args = eval(args, envir = parent.frame(),
                enclos = baseenv())
    new_vars = keep_helper(vars, args)
    res = data[ , new_vars, drop = FALSE]
    colnames(res) = vars[new_vars] # prevents names correction
    res
}

#' @export
#' @rdname keep
except = function(data, ...){
    UseMethod("except")
}

# # @export
# except.default = function(data, ...){
#     vars = names(data)
#     args = substitute(list(...))
#     args = substitute_symbols(args,
#                               list("%to%" = ".internal_to_")
#     )
#     args = eval(args)
#     new_vars = keep_helper(vars, args)
#     new_vars = -unique(new_vars)
#     if(length(new_vars)==0){
#         return(data)
#     }
#     res = data[new_vars]
#     names(res) = vars[new_vars] # prevents names correction
#     res
# }

#' @export
except.list = function(data, ...){
    for(each in seq_along(data)){
        data[[each]] = eval(
            substitute(except(data[[each]], ...)), 
            envir = parent.frame(),
            enclos = baseenv()
        )
    }
    data
}

#' @export
except.data.frame = function(data, ...){
    vars = colnames(data)
    args = substitute(list(...))
    args = substitute_symbols(args,
                              list("%to%" = ".internal_to_")
    )
    args = eval(args, envir = parent.frame(),
                enclos = baseenv())
    new_vars = keep_helper(vars, args)
    new_vars = -unique(new_vars)
    if(length(new_vars)==0){
        return(data)
    }
    if(is.data.table(data)){
        res = data[ , new_vars, with = FALSE]
    } else {
        res = data[ , new_vars, drop = FALSE]
        colnames(res) = vars[new_vars] # prevents names correction    
    }
    res
}

#' @export
except.matrix = function(data, ...){
    vars = colnames(data)
    args = substitute(list(...))
    args = substitute_symbols(args,
                              list("%to%" = ".internal_to_")
    )
    args = eval(args, envir = parent.frame(),
                enclos = baseenv())
    new_vars = keep_helper(vars, args)
    new_vars = -unique(new_vars)
    if(length(new_vars)==0){
        return(data)
    }
    res = data[ , new_vars, drop = FALSE]
    colnames(res) = vars[new_vars] # prevents names correction
    res
}



keep_helper = function(old_names, args){
    keep_names = numeric(0)
    new_names = rapply(args, function(each){
        if(!is.function(each) && !is.character(each)){
            as.character(each)
        } else {
            each
        }
    }, how = "unlist")
    # new_names = c(args, recursive = TRUE)
    characters_names = character(0) # for checking non-existing names
    for (each in new_names){
        if(is.character(each)){
            if(any(grepl("`", each))){
                each = eval(substitute(subst(each)), 
                            envir = parent.frame(2),
                            enclos = baseenv()
                )
            } 
            next_names = which(old_names %in% each)
            characters_names = c(characters_names, each)
        } else {
            next_names = which(old_names %in% (old_names %i% each))
        }
        keep_names = c(keep_names, next_names %d% keep_names)
    }
    if(anyDuplicated(characters_names)){
        warning("duplicated names: ", 
                paste(characters_names[duplicated(characters_names)], collapse = ","),
                ". Repeated names are ignored."
                
        )
    }
    stopif(any(!(characters_names %in% old_names)), 
           "names not found: '", paste(characters_names %d% old_names, collapse = "', '"),"'")
    keep_names
    
}


    
#' @export
#' @rdname keep
'%keep%' = function(data, variables){
    # data = substitute(data)
    # variables = substitute(variables)
    eval(
       substitute(keep(data, variables)),
        envir = parent.frame(),
        enclos = baseenv()
    )
}

#' @export
#' @rdname keep
'%except%' = function(data, variables){
    # data = substitute(data)
    # variables = substitute(variables)
    eval(
        substitute(except(data, variables)),
        envir = parent.frame(),
        enclos = baseenv()
    )
}

#' @export
#' @rdname keep
.keep = function(...){
    reference = suppressMessages(default_dataset() )
    data = ref(reference)
    # args = substitute(list(...))
    data = eval(
        substitute(keep(data, ...)), 
        envir = parent.frame(),
        enclos = baseenv()                
    )
    ref(reference) = data
    invisible(data)
}

#' @export
#' @rdname keep
.except = function(...){
    reference = suppressMessages(default_dataset() )
    data = ref(reference)
    # args = substitute(list(...))
    data = eval(
        substitute(except(data, ...)), 
        envir = parent.frame(),
        enclos = baseenv()                
    )
    ref(reference) = data
    invisible(data)
}
