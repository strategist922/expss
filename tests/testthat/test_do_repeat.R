context("do_repeat")

data(iris)

test_iris = iris
test_iris$i1 = 10
test_iris$i2 = 20
test_iris$i3 = 30

res_iris = iris

res_iris = do_repeat(iris, i = qc(i1, i2, i3), value = c(10, 20, 30), 
    {
    i = value
})



expect_identical(res_iris, test_iris)


test_iris$i1 = 1L
test_iris$i2 = 2L
test_iris$i3 = 3L


res_iris = do_repeat(iris, i = qc(i1, i2, i3), 
                     {
                         i = .item_num
                     })


expect_identical(res_iris, test_iris)

k = 42
test_iris = iris
test_iris$i1 = 42
test_iris$i2 = 42
test_iris$i3 = 42


res_iris = do_repeat(iris, i = qc(i1, i2, i3),
                     {
                         i = k
                     })


expect_identical(res_iris, test_iris)


expect_error(do_repeat(res_iris, i = qc(i1, i2, i3), c(10, 20, 30), 
                       {
                           i = value
                       }))

expect_error(do_repeat(res_iris, i = qc(i1, i2, i3), value = c(10, 20), 
                       {
                           i = value
                       }))


data(iris)

test_iris = iris
test_iris[, paste0(letters[1], seq_len(1))] = 1
test_iris[, paste0(letters[2], seq_len(2))] = 2
test_iris[, paste0(letters[3], seq_len(3))] = 3


res_iris = do_repeat(iris, i = c(1, 2, 3),
                     {
                         set(paste0(letters[i], seq_len(i)), i)
                     })


expect_identical(res_iris, test_iris)


data(iris)

test_iris = iris
set.seed(123)
test_iris$i1 = runif(nrow(iris))
test_iris$i2 = runif(nrow(iris))
test_iris$i3 = runif(nrow(iris))


set.seed(123)
res_iris = do_repeat(iris, i = qc(i1, i2, i3), 
          {
              i = runif(.N)
          })

expect_identical(res_iris, test_iris)
expect_error(do_repeat(iris, i = qc(i1, i2, i3), 
                       {
                           i = runif(5)
                       }))

test_iris = iris
test_iris$log = log(iris$Sepal.Length)
test_iris$exp = exp(iris$Sepal.Length)

res_iris = iris

res_iris = do_repeat(res_iris, i = qc(log, exp), fun = qc(log, exp), 
                      {
                         i = fun(Sepal.Length)
                     })

expect_identical(res_iris, test_iris)

data(iris)
test_iris = iris

test_iris$a = 16
res_iris = do_repeat(iris, i= 4, {
    a = sum(c(i, i, i, i))
    
    
})

expect_identical(res_iris, test_iris)

data(iris)
test_iris = iris[, "Species", drop = FALSE]


res_iris = do_repeat(iris, i= qc(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width), {
    i = NULL

})

expect_identical(res_iris, test_iris)

context("do_repeat default_dataset")

data(iris)
def_iris = iris
default_dataset(def_iris)

test_iris = iris
test_iris$i1 = 10
test_iris$i2 = 20
test_iris$i3 = 30

res_iris = iris

.do_repeat(i = qc(i1, i2, i3), value = c(10, 20, 30),
           {
               i = value
           })

expect_identical(def_iris, test_iris)

k = 42
test_iris = iris
test_iris$i1 = 42
test_iris$i2 = 42
test_iris$i3 = 42

def_iris = iris
default_dataset(def_iris)
.do_repeat(i = qc(i1, i2, i3),
                     {
                         i = k
                     })

expect_identical(def_iris, test_iris)


test_iris = iris
test_iris$i1 = 43
test_iris$i2 = 43
test_iris$i3 = 43

def_iris = iris
default_dataset(def_iris)
fff = function(){
    j = 43
    .do_repeat(i = qc(i1, i2, i3),
               {
                   i = j
               })
}
fff()
expect_identical(def_iris, test_iris)


data(iris)

old_names = qc(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
new_names = paste0("scaled_", old_names)

test_iris = iris

test_iris[, new_names[1]] = scale(iris[, old_names[1]])
test_iris[, new_names[2]] = scale(iris[, old_names[2]])
test_iris[, new_names[3]] = scale(iris[, old_names[3]])
test_iris[, new_names[4]] = scale(iris[, old_names[4]])

scaled_iris = do_repeat(iris, orig = old_names, scaled = new_names,  {
    scaled = scale(orig)
    
})
expect_identical(scaled_iris, test_iris)

context("do_repeat.list")

data(iris)
list_iris = split(iris, iris$Species) 

test_iris = iris
test_iris$i1 = 10
test_iris$i2 = 20
test_iris$i3 = 30

res_iris = split(test_iris, iris$Species) 
expect_identical(do_repeat(list_iris, i = qc(i1, i2, i3), value = c(10, 20, 30), 
                           {
                               i = value
                           }), res_iris)


data(iris)
list_iris = split(iris, iris$Species) 

old_names = qc(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
new_names = paste0("scaled_", old_names)

res_iris = split(iris, iris$Species)

for(i in seq_along(res_iris)){
    for(j in seq_along(old_names)){
        res_iris[[i]][[new_names[j]]] = scale(res_iris[[i]][[old_names[j]]])
    }
}


expect_identical(do_repeat(list_iris, orig = old_names, scaled = new_names,  {
    scaled = scale(orig)
    
}), res_iris)


