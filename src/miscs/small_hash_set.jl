"""
    SmallHashSet{N,T}

A small hash set implementation with a fixed maximum capacity `N` and element type `T`.

# Fields
- `data::NTuple{N,T}`: A tuple to store the elements of the hash set.
- `count::Int`: The current number of elements in the hash set.

# Constructors
- `SmallHashSet{N,T}()`: Creates an empty `SmallHashSet` with capacity `N` and element type
    `T`.
- `SmallHashSet(elements::AbstractVector{T})`: Creates a `SmallHashSet` initialized with the
    unique elements from the provided vector. The capacity `N` is automatically determined
    from the number of unique elements.

# Constructor Arguments
- `elements::AbstractVector{T}`: A vector of elements to initialize the hash set.

# Returns
- `SmallHashSet{N,T}`: A new `SmallHashSet` instance.
"""
mutable struct SmallHashSet{N,T}
    data::NTuple{N,T}
    count::Int

    SmallHashSet{N,T}() where {N,T} = new{N,T}(ntuple(_ -> zero(T), N), 0)

    function SmallHashSet(elements::AbstractVector{T}) where {T}
        u_elements = unique(elements)
        N = length(u_elements)

        s = new{N,T}(tuple(u_elements...), N)
        return s
    end
end

function Base.empty!(s::SmallHashSet{N,T}) where {N,T}
    s.count = 0
    s.data = ntuple(_ -> zero(T), N)
end

Base.iterate(s::SmallHashSet{N,T}) where {N,T} = s.count == 0 ? nothing : (s.data[1], 2)
function Base.iterate(s::SmallHashSet{N,T}, i) where {N,T}
    return i > s.count ? nothing : (s.data[i], i + 1)
end

Base.in(x, s::SmallHashSet{N,T}) where {N,T} = any(e -> e == x, s.data[1:s.count])

Base.length(s::SmallHashSet{N,T}) where {N,T} = s.count

function Base.push!(s::SmallHashSet{N,T}, x::T) where {N,T}
    @assert s.count ≤ N "SmallHashSet overflow – increase N"
    for i = 1:s.count
        if s.data[i] == x
            return s # already there → nothing to do
        end
    end

    # store at the next free slot
    s.data = Base.setindex(s.data, x, s.count + 1)

    s.count += 1
    return s
end

function Base.hash(s::SmallHashSet{N,T}, h::UInt) where {N,T}
    return hash(s.data, hash(s.count, hash(:BaseNumber, h)))
end

function Base.:(==)(s1::SmallHashSet{N,T}, s2::SmallHashSet{N,T}) where {N,T}
    return (s1.count == s2.count) && (s1.data == s2.data)
end

function Base.isequal(s1::SmallHashSet{N,T}, s2::SmallHashSet{N,T}) where {N,T}
    return (s1.count == s2.count) && (s1.data == s2.data)
end
