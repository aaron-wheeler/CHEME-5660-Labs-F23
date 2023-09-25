# define expectation -
_𝔼(X::Array{Float64,1}, p::Array{Float64,1}) = sum(X.*p)

"""
    analyze(R::Array{Float64,1};  Δt::Float64 = (1.0/365.0)) -> Tuple{Float64,Float64,Float64}
"""
function analyze(R::Array{Float64,1};  Δt::Float64 = (1.0/365.0))::Tuple{Float64,Float64,Float64}
    
    # initialize -
    u,d,p = 0.0, 0.0, 0.0;
    darray = Array{Float64,1}();
    uarray = Array{Float64,1}();
    N₊ = 0;

    # up -
    # compute the up moves, and estimate the average u value -
    index_up_moves = findall(x->x>0, R);
    for index ∈ index_up_moves
        R[index] |> (μ -> push!(uarray, exp(μ*Δt)))
    end
    u = mean(uarray);

    # down -
    # compute the down moves, and estimate the average d value -
    index_down_moves = findall(x->x<0, R);
    for index ∈ index_down_moves
        R[index] |> (μ -> push!(darray, exp(μ*Δt)))
    end
    d = mean(darray);

    # probability -
    N₊ = length(index_up_moves);
    p = N₊/length(R);

    # return -
    return (u,d,p);
end

"""
    𝔼(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64
"""
function 𝔼(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # initialize -
    expected_value = 0.0;
    X = Array{Float64,1}();
    p = Array{Float64,1}();

    # get the levels dictionary -
    levels = model.levels;
    nodes_on_this_level = levels[level]
    for i ∈ nodes_on_this_level

        # grab the node -
        node = model.data[i];
        
        # get the data -
        x_value = node.price;
        p_value = node.probability;

        # store the data -
        push!(X,x_value);
        push!(p,p_value);
    end

    # compute -
    expected_value = _𝔼(X,p) # inner product

    # return -
    return expected_value
end

"""
    𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; 
        startindex::Int64 = 0) -> Array{Float64,2}

Computes the expectation of the model simulation. Takes a model::MyBinomialEquityPriceTree instance and a vector of
tree levels, i.e., time steps and returns a variance array where the first column is the time and the second column is the expectation.
Each row is a time step.
"""
function 𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; 
    startindex::Int64 = 0)::Array{Float64,2}

    # initialize -
    number_of_levels = length(levels);
    expected_value_array = Array{Float64,2}(undef, number_of_levels, 2);

    # loop -
    for i ∈ 0:(number_of_levels-1)

        # get the level -
        level = levels[i+1];

        # get the expected value -
        expected_value = 𝔼(model, level=level);

        # store -
        expected_value_array[i+1,1] = level + startindex;
        expected_value_array[i+1,2] = expected_value;
    end

    # return -
    return expected_value_array;
end

Var(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) = _𝕍(model, levels, startindex = startindex)

"""
    𝕍(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64
"""
function _𝕍(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # initialize -
    variance_value = 0.0;
    X = Array{Float64,1}();
    p = Array{Float64,1}();

    # get the levels dictionary -
    levels = model.levels;
    nodes_on_this_level = levels[level]
    for i ∈ nodes_on_this_level
 
        # grab the node -
        node = model.data[i];
         
        # get the data -
        x_value = node.price;
        p_value = node.probability;
 
        # store the data -
        push!(X,x_value);
        push!(p,p_value);
    end

    # update -
    variance_value = (_𝔼(X.^2,p) - (_𝔼(X,p))^2)

    # return -
    return variance_value;
end

"""
    𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) -> Array{Float64,2}

Computes the variance of the model simulation. Takes a model::MyBinomialEquityPriceTree instance and a vector of
tree levels, i.e., time steps and returns a variance array where the first column is the time and the second column is the variance.
Each row is a time step.
"""
function _𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0)::Array{Float64,2}

    # initialize -
    number_of_levels = length(levels);
    variance_value_array = Array{Float64,2}(undef, number_of_levels, 2);

    # loop -
    for i ∈ 0:(number_of_levels - 1)
        level = levels[i+1];
        variance_value = _𝕍(model, level=level);
        variance_value_array[i+1,1] = level + startindex
        variance_value_array[i+1,2] = variance_value;
    end

    # return -
    return variance_value_array;
end
