#' Options for contolling behaviour of the package
#' 
#' All options can be set with \code{options(option.name = option.value)}. You
#' can get value of option with \code{getOption("option.name").}
#' \itemize{
#' \item{\code{expss.digits} }{ Number of digits after decimal separator which will be 
#' shown for tables. This parameter is supported in the \link[expss]{datatable},
#'  \link[expss]{htmlTable.etable} and \code{print} methods. \code{NULL} is
#' default and means 1 digit. \code{NA} means no rounding.}
#' \item{\code{expss.enable_value_labels_support} }{By default, all labelled 
#' variables will use labels as labels for factor levels when \link{factor} is 
#' called. So any function which calls \link{factor}/\link{as.factor} will use 
#' value labels. In details this option changes behavior of two methods for class 
#' \code{labelled} - \code{as.character} and \code{unique} - on which
#' \code{factor} depends entirely. If you have compatibility problems set this
#' option to zero: \code{options(expss.enable_value_labels_support = 0)}.}
#' \item{\code{expss.output} }{ By default tables are printed in the 
#' console. You can change this behavior by setting this option. There are three
#' possible values: \code{'rnotebook'}, \code{'viewer'} or  \code{'raw'}. First
#' option is useful when you run your code in the R Notebook - output will be
#' rendered to nice HTML. The second option will render tables to RStudio
#' viewer. \code{knitr} is supported automatically via \code{knit_print} method.
#' Option \code{raw} disables any formatting and all tables are printed as
#' data.frames.} }
#' 
#' @name expss.options
NULL