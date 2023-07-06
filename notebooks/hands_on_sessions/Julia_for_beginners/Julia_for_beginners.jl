# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.11.3
#   kernelspec:
#     display_name: Julia 1.9.1
#     language: julia
#     name: julia-1.9
# ---

# # Global Workshop on Earth Observation with Julia
# - 9-13 January 2023
# - Terceira Island, Azores (Timezone: UTC -1; GMT-1), Portugal, AIR Centre

# ## Julia for beginners
# > 10:20 – 12:15 Hands-on session 1
#
# > Lazaro Alonso  
# <img src="https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg" width=20/> https://github.com/lazarusA 
# > - <font color = teal> **Max Planck Institute for Biogeochemistry** </font>
# > - Model-Data Integration Group 
# - lalonso@bgc-jena.mpg.de
#
# Find me also on social media:
#
# <img src="https://upload.wikimedia.org/wikipedia/commons/d/d5/Mastodon_logotype_%28simple%29_new_hue.svg" width=30/>
# <font color = dodgerblue> https://julialang.social/@LazaroAlonso </font>
#
# <img src="https://upload.wikimedia.org/wikipedia/commons/4/4f/Twitter-logo.svg" width=30/>
# <font color = dodgerblue>  https://twitter.com/LazarusAlon </font>
#

# #### References:
# - https://juliadatascience.io
#     > by Jose Storopoli, Rik Huijzer and Lazaro Alonso
#     
# Here I will try to follow the workflow/logic from this book.
# - https://docs.julialang.org
# - https://docs.julialang.org/en/v1/manual/performance-tips/

# **Disclaimer:** 
#
# I'm just a user of the language like you, hence any developer's perspective or in depth technicalities are out of the scope of this talk. 

# **Overview**

# ## What is Julia?
#
# * Published around 2012 initially developped at the MIT
# * Just in Time compiled
# * Optionally typed
# * Gives you the best of C, Matlab and Python
# * Function oriented not object oriented
# * solves the two language problem

# #### 10:20-10:40 Language Syntax
# - **Variables**
# - struct
# - Boolean Operators and Numeric comparisons
# - Functions
# - Multiple Dispatch
# - Keyword arguments
# - Anonymous Functions
# - Conditionals

name = "Julia"
age = 11 # years

name

# operations on variables, addition, multiplication
10*age

10 + age

# Q. What type of variables are those? 
# > Use `typeof` and find out. 

typeof(age)

typeof(name)

# - Variables
# - **struct**
# - Boolean Operators and Numeric comparisons
# - Functions
# - Multiple Dispatch
# - Keyword arguments
# - Anonymous Functions
# - Conditionals

# Having variables around without any sort of hierarchy or relationships is not ideal. In Julia, we can define that kind of structured data with a struct (also known as a composite type).
#
# _Basic, basic, of course the following is not the whole story, but is enough to get us started_
#
# - https://docs.julialang.org/en/v1/manual/performance-tips/#Type-declarations

struct Language
    name::String
    title::String
    year_of_birth::Int64
    fast::Bool
end

fieldnames(Language)

# Q. How to use them?
# > Instantiate as in:

julia = Language("Julia", "Rapidus", 2012, true)

python = Language("Python", "Letargicus", 1991, false)

# <font color=red>We can’t change their values once they are instantiated.</font>
# But, what if I want to update some of those variables, then we use a `mutable struct`.

mutable struct MutableLanguage
    name::String
    title::String
    year_of_birth::Int64
    fast::Bool
end

julia_mutable = MutableLanguage("Julia", "Rapidus", 2012, true)

julia_mutable.title = "Python Obliteratus"

julia_mutable

# - Variables
# - struct
# - **Boolean Operators and Numeric comparisons**
# - Functions
# - Multiple Dispatch
# - Keyword arguments
# - Anonymous Functions
# - Conditionals

# ** ! NOT, && AND, || OR**

!true

(false && true) || (!false)

(6 isa Int64) && (6 isa Real)

# equality
1 == 1

# less than
1<2

# less than or equal to
3.14 <= 3.14

# mix with boolean 
(1 != 10) || (3.14 <= 2.71)

# - Variables
# - struct
# - Boolean Operators and Numeric comparisons
# - **Functions**
# - **Multiple Dispatch**
# - Keyword arguments
# - Anonymous Functions
# - Conditionals

f_name(arg1, arg2) = arg1 + arg2

function fuction_name(arg1, arg2)
    return arg1 + arg2
end

f(x,y) = x + y

f(1,2)

f(2.0, 1.0)

VERSION

# <font color = red > type declarations </font> Multiple dispatch
#
# - https://docs.julialang.org/en/v1/manual/methods/#Defining-Methods

function round_number(x::Float64)
    return round(x)
end

function round_number(x::Int64)
    return x
end

# **multiple return values**

function add_multiply(x, y)
    addition = x + y
    multiplication = x * y
    return addition, multiplication
end

add_multiply(1, 2)

out = add_multiply(1, 2)

first(out)

last(out)

# - Variables
# - struct
# - Boolean Operators and Numeric comparisons
# - Functions
# - Multiple Dispatch
# - **Keyword arguments**
# - Anonymous Functions
# - Conditionals

function logarithm(x::Real; base::Real=2.7182818284590)
    return log(base, x)
end

logarithm(10)

logarithm(10; base=2)

# - Variables
# - struct
# - Boolean Operators and Numeric comparisons
# - Functions
# - Multiple Dispatch
# - Keyword arguments
# - **Anonymous Functions**
# - Conditionals

# Often we don’t care about the name of the function and want to quickly make one.

map(x -> 2.7182818284590^x, logarithm(2))

# - Variables
# - struct
# - Boolean Operators and Numeric comparisons
# - Functions
# - Multiple Dispatch
# - Keyword arguments
# - Anonymous Functions
# - **Conditionals**

# Let's compare two numbers, `a` and `b`.

function compare(a, b)
    if a < b
        "a is less than b"
    elseif a > b
        "a is greater than b"
    else
        "a is equal to b"
    end
end

compare(3.14, 3.14)

# A pattern that I use a lot is the following:

function compare_ternary(a, b)
    a < b ? "a is less than b" : a > b ? "a is greater than b" : "a is equal to b"
end

compare_ternary(3.14, 3.14)

# **The `for` loop ! Use it!**

for i in 1:5
    println(i)
end

for i ∈ 1:5
    println(i)
end

# #### 10:40-11:00 Native Data Structures
# - **String**
# - Tuple
# - NamedTuple
# - UnitRange
# - Array
# - Pair
# - Dict
# - Symbol

str1 = "This is a string"

typeof(str1)

str2 = """
    This is a big multiline string with a nested "quotation".
    As you can see.
    It is still a String to Julia.
    """

typeof(str2)

# concatenation
hello = "Hello"
goodbye = "Goodbye"

hello*goodbye

join([hello, goodbye], " ")

# String Interpolation
"$hello $goodbye"

function compare_interpolate(a, b)
    a < b ? "$a is less than $b" : a > b ? "$a is greater than $b" : "$a is equal to $b"
end

compare_interpolate(3.14, 3.14)

# **Functions to manipulate strings**

julia_string = "Julia is an amazing open source programming language"

contains(julia_string, "Julia")

startswith(julia_string, "Julia")

endswith(julia_string, "Julia")

lowercase(julia_string)

uppercase(julia_string)

titlecase(julia_string)

lowercasefirst(julia_string)

replace(julia_string, "amazing" => "awesome")

split(julia_string, " ")

# **String Conversions**

string(123)

parse(Int64, "123")

# - String
# - **Tuple**
# - NamedTuple
# - UnitRange
# - Array
# - Pair
# - Dict
# - Symbol

my_tuple = (1, 3.14, "Julia") # immutable struct

add_mul = add_multiply(1, 2)

typeof(add_mul)

# Mix anonymous functions and tuples

map((x, y) -> x^y, 2, 3)

map((x, y, z) -> x^y + z, 2, 3, 1)

# - String
# - Tuple
# - **NamedTuple**
# - UnitRange
# - Array
# - Pair
# - Dict
# - Symbol

my_namedtuple = (i=1, f=3.14, s="Julia")

my_namedtuple.f

it = 1
ft = 3.14
st = "Julia"

# Begin the named tuple construction by specifying first a semicolon ; before the values

my_quick_namedtuple = (; it, ft, st)

# - String
# - Tuple
# - NamedTuple
# - **UnitRange**
# - Array
# - Pair
# - Dict
# - Symbol

1:10

typeof(1:10)

0.0:0.2:1.0

typeof(0.0:0.2:1.0)

# - String
# - Tuple
# - NamedTuple
# - UnitRange
# - **Array**
# - Pair
# - Dict
# - Symbol

# If you want to _materialize_ a range into a collection, you can use the function `collect`

collect(1:5)

myarray = [1, 2, 3]

# Let’s start with array types. There are several, but we will focus on the following two
#
# - Vector{T}: one-dimensional array. Alias for Array{T, 1}.
# - Matrix{T}: two-dimensional array. Alias for Array{T, 2}.

my_vector = Vector{Float64}(undef, 10)

my_matrix = Matrix{Float64}(undef, 10, 2)

# **Common arrays**

zeros(3,3)

ones(Int64, 3,3)

# This also works: (array literals)

[[1 2]
 [3 4]]

Float64[[1 2]
        [3 4]]

# mix and match
[ones(Int, 2, 2) zeros(Int, 2, 2)]

# array comprehension
[x^2 for x in 1:5]

[x*y for x in 1:5 for y in 1:2]

[x*y for x in 1:5, y in 1:2]

# conditional
[x^2 for x in 1:5 if isodd(x)]

# **Concatenation**: to chain together.

cat(ones(2), zeros(2), dims=1) # vcat

cat(ones(2), zeros(2), dims=2) # hcat

# **Array Inspection**
# - What type of elements are inside an array ? 

eltype(myarray)

length(myarray) # total number of elements

ndims(myarray) # number of dimensions

size(myarray) # array’s dimensions

size(myarray, 1)

# **Indexing and slicing**

# example vector
ex_vec = [1, 2, 3, 4, 5]

# example matrix
ex_mat = [[1 2 3]
          [4 5 6]
          [7 8 9]]

ex_vec[3]

ex_mat[2,1]

ex_vec[end]

ex_mat[end, begin]

# **slicing**

ex_vec[2:4]

ex_mat[2, :]

# **Manipulations**

ex_mat[2,2] = 100

ex_mat

ex_mat[3, :] = [17,16,15]

ex_mat

# `reshape`

six_vector = [1, 2, 3, 4, 5, 6]

three_two_matrix = reshape(six_vector, (3, 2))

reshape(three_two_matrix, (6, ))

# **Apply a function over every array element**

log.(ex_mat)

# Dot `.` operator, broadcasting

ex_mat .+ 100

map(log, ex_mat)

map(x -> 3x, ex_mat)

(x -> 3x).(ex_mat)

# `mapslices`

mapslices(sum, ex_mat; dims=1)

mapslices(sum, ex_mat; dims=2)

# **Array Iteration**

# +
simple_vector = [1, 2, 3]

empty_vector = Int64[]

for i in simple_vector
    push!(empty_vector, i + 1)
end

empty_vector

# +
forty_twos = [42, 42, 42]

empty_vector = Int64[]

for i in eachindex(forty_twos)
    push!(empty_vector, i)
end

empty_vector
# -

# - String
# - Tuple
# - NamedTuple
# - UnitRange
# - Array
# - **Pair**
# - **Dict**
# - **Symbol**

my_pair = "Julia" => 42

name2number_map = Dict("one" => 1, "two" => 2)

sym = :some_text

# **Splat Operator**

add_elements(a, b, c) = a + b + c

my_collection = [1, 2, 3]

add_elements(my_collection...)

add_elements(1:3...)

# #### 11:00-11:20 using Pkg
# - **Project Management**
# - DataFrames
# - Create a DataFrame
# - using CSV
# - write and read
# - name and slicing

using Pkg

Pkg.status()

Pkg.activate(".")

Pkg.status()

Pkg.add("DataFrames")

Pkg.status()

using DataFrames

 df = DataFrame(; name=["Sally", "Bob", "Alice", "Hank"],
    grade_2020=[1, 5, 8.5, 4])

Pkg.add("CSV")

Pkg.status()

using CSV

CSV.write("grades.csv", df)

df = CSV.read("grades.csv", DataFrame)

df.name

df[!, :name] # :grade_2020

# makes a new copy
df[:, :name]

df[1, :name]

df[1:2, :name]

# #### 11:20-11:40 Tabular data
# - **filter**
# - subset
# - select
# - Categorical Data
# - **Join**
# - innerjoin, outerjoin, crossjoin, leftjoin, rightjoin, semijoin, antijoin

filter(x-> x>3, [1,2,3,4,5])

# For DataFrames
#
# `filter(source => f::Function, df)`

df

# for DataFrames
equals_alice(name) = name == "Alice"

filter(:name => equals_alice, df)

# Also works for a vector!

filter(equals_alice, ["Alice", "Bob", "Dave"])

# anonymous function
filter(:name => n -> n == "Alice", df)

# Maybe a better way will be:

filter(:name => ==("Alice"), df)

# Or, not Alice ? 

filter(:name => !=("Alice"), df)

# - filter
# - **subset**
# - select
# - Categorical Data
# - **Join**
# - innerjoin, outerjoin, crossjoin, leftjoin, rightjoin, semijoin, antijoin

# `subset` works on complete columns

subset(df, :name => ByRow(equals_alice))

subset(df, :name => ByRow(name -> name == "Alice"))

subset(df, :name => ByRow(==("Alice")))

# - filter
# - subset
# - **select**
# - Categorical Data
# - **Join**
# - innerjoin, outerjoin, crossjoin, leftjoin, rightjoin, semijoin, antijoin

function responses()
    id = [1, 2]
    q1 = [28, 61]
    q2 = [:us, :fr]
    q3 = ["F", "B"]
    q4 = ["B", "C"]
    q5 = ["A", "E"]
    DataFrame(; id, q1, q2, q3, q4, q5)
end

resp = responses()

select(resp, :id, :q1)

select(resp, "id", "q1", "q2")

# regex
select(resp, r"^q")

select(resp, Not(:q5))

select(resp, Not([:q4, :q5]))

# mix and match columns that we want to preserve with columns that we do Not want
select(resp, :q5, Not(:q5))

select(resp, :q5, :)

# **renaming columns via `select`**

select(resp, 1, :q1, :q2)

select(resp, 1 => "participant", :q1 => "age", :q2 => "nationality")

# - filter
# - subset
# - select
# - **Categorical Data**
# - **Join**
# - innerjoin, outerjoin, crossjoin, leftjoin, rightjoin, semijoin, antijoin

Pkg.add(["CategoricalArrays", "Dates"])

using CategoricalArrays, Dates

function date_col()
    id = 1:4
    date =Date.(["28-01-2018", "03-04-2019", "01-08-2018", "22-11-2020"],
        dateformat"dd-mm-yyyy")
    age = ["adolescent", "adult", "infant", "adult"]
    DataFrame(; id, date, age)
end

date_col()

sort(date_col(), :age)

function fix_categ(df)
    levels = ["infant", "adolescent", "adult"]
    ages = categorical(df[!, :age]; levels, ordered=true)
    df[!, :age] = ages
    df
end

df_categ = fix_categ(date_col())

a = df_categ[1, :age]
b = df_categ[2, :age]
a < b

# - filter
# - subset
# - select
# - Categorical Data
# - **Join**
# - innerjoin, outerjoin, crossjoin, leftjoin, rightjoin, semijoin, antijoin

df_2021 = DataFrame(; name=["Bob 2", "Sally", "Hank"],
grade_2021=[9.5, 9.5, 6])

innerjoin(df, df_2021)

innerjoin(df, df_2021, on=:name)

# Do the others !



# #### 11:40-12:15 Variable Transformations
# - **transform**
# - groupby
# - combine
# - dropmissing
# - coalesce [replace missing values]
# - skipmissing

plus_one(grades) = grades .+ 1

transform(df, :grade_2020 => plus_one)

# rename
transform(df, :grade_2020 => plus_one => :grade_2020)

# rename false
transform(df, :grade_2020 => plus_one; renamecols=false)

# - transform
# - **groupby**
# - **combine**
# - dropmissing
# - coalesce [replace missing values]
# - skipmissing

function all_grades(df1, df2)
    df1 = select(df1, :name, :grade_2020 => :grade)
    df2 = select(df2, :name, :grade_2021 => :grade)
    rename_bob2(data_col) = replace.(data_col, "Bob 2" => "Bob")
    df2 = transform(df2, :name => rename_bob2 => :name)
    return vcat(df1, df2)
end

df_grades = all_grades(df, df_2021)

groupby(df_grades, :name)

Pkg.add("Statistics")

using Statistics

gdf = groupby(df_grades, :name)
combine(gdf, :grade => mean)

# But what if we want to apply a function to multiple columns of our dataset?

group = [:A, :A, :B, :B]
X = 1:4
Y = 5:8
df_g = DataFrame(; group, X, Y)

gdf = groupby(df_g, :group)
combine(gdf, [:X, :Y] .=> mean; renamecols=false)

# - transform
# - groupby
# - combine
# - **dropmissing**
# - **coalesce [replace missing values]**
# - skipmissing

df_missing = DataFrame(;
    name=[missing, "Sally", "Alice", "Hank"],
    age=[17, missing, 20, 19],
    grade_2020=[5.0, 1.0, missing, 4.0],
)

dropmissing(df_missing)

dropmissing(df_missing, :name)

dropmissing(df_missing, [:name, :age])

filter(:name => !ismissing, df_missing)

coalesce.([missing, "some value", missing], "zero")

# - transform
# - groupby
# - combine
# - dropmissing
# - coalesce [replace missing values]
# - **skipmissing**

combine(df_missing, :grade_2020 => mean)

combine(df_missing, :grade_2020 => mean ∘ skipmissing )

# #### Summary
# - Language Syntax
# - Native Data Structures
# - using Pkg
# - Tabular data
# - Variable Transformations

Pkg.status()

#
