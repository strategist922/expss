% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sort.R
\name{sort_asc}
\alias{sort_asc}
\alias{\%sort_asc\%}
\alias{.sort_asc}
\alias{sort_asc<-}
\alias{sort_desc}
\alias{.sort_desc}
\alias{\%sort_desc\%}
\alias{sort_desc<-}
\title{Sort data.frames/matrices/vectors}
\usage{
sort_asc(data, ..., na.last = FALSE)

data \%sort_asc\% variables

.sort_asc(..., na.last = FALSE)

sort_asc(data) <- value

sort_desc(data, ..., na.last = TRUE)

.sort_desc(..., na.last = TRUE)

data \%sort_desc\% variables

sort_desc(data) <- value
}
\arguments{
\item{data}{data.frame/matrix/vector}

\item{...}{character/numeric. Column names/numbers for data.frame/matrix by
which object will be sorted. Ignored for vectors.}

\item{na.last}{for controlling the treatment of NAs. If TRUE, missing values
in the data are put last; if FALSE, they are put first; if NA, they are
removed.}

\item{variables}{character/numeric. Column names/numbers for data.frame/matrix by
which object will be sorted for infix functions. Ignored for vectors.}

\item{value}{character/numeric. Column names/numbers for data.frame/matrix by
which object will be sorted. The same as \code{...} but for assignment
versions of functions.}
}
\value{
sorted \code{data}
}
\description{
\code{sort_asc} sorts in ascending order and \code{sort_desc} sorts in 
descending order. There is no non-standard evaluation in these functions by 
design so use quotes for names of your variables or use \link{qc}.
\code{\%sort_asc\%}/\code{\%sort_desc\%} are infix versions of these functions. 
\code{.sort_asc}/\code{.sort_desc} are versions for working with
\link{default_dataset}.
}
\examples{
data(mtcars)
sort_asc(mtcars, "mpg")
sort_asc(mtcars, "cyl", "mpg") # by two column

# same results with column nums
sort_asc(mtcars, 1)
sort_asc(mtcars, 2:1) # by two column
sort_asc(mtcars, 2, 1) # by two column

# 'qc'  usage
sort_asc(mtcars, qc(cyl, mpg)) 

# infix version
mtcars \%sort_asc\% "mpg"
mtcars \%sort_asc\% c("cyl", "mpg")
mtcars \%sort_asc\% qc(cyl, mpg) 

}
