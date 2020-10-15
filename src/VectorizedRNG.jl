module VectorizedRNG

using VectorizationBase, Random, UnPack
using VectorizationBase: REGISTER_SIZE, gep, _Vec, ifelse, VecUnroll, AbstractSIMD, rotate_right, vadd, vsub, zero_offsets, vfmadd, vfmsub, vfnmadd, shufflevector

using Distributed: myid

export local_rng, rand!, randn!#, randexp, randexp!

const vloada = vload
const vstorea! = vstore!
const CACHELINE_SIZE = VectorizationBase.L₁CACHE.linesize

abstract type AbstractVRNG{N} <: Random.AbstractRNG end
abstract type AbstractState{N,W} end

const W64 = REGISTER_SIZE >> 3
const W32 = REGISTER_SIZE >> 2
const W16 = REGISTER_SIZE >> 1

include("masks.jl")
include("api.jl")
include("special_approximations.jl")
include("xoshiro.jl")
# const GLOBAL_vPCGs = Ref{Ptr{UInt64}}()


const GLOBAL_vRNGs = Ref{Ptr{UInt64}}()

local_rng(i) = Xoshift{XREGISTERS}(i*4REGISTER_SIZE*XREGISTERS + GLOBAL_vRNGs[])
local_rng() = local_rng(Base.Threads.threadid() - 1)

# include("precompile.jl")
# _precompile_()

# const RANDBUFFER32 = Float32[]
# const RANDNBUFFER32 = Float32[]
# const RANDBUFFER64 = Float64[]
# const RANDNBUFFER64 = Float64[]
# const RANDBUFFERCOUNTER = UInt8[]
# const RANDNBUFFER32COUNTER = UInt8[]
# const RANDBUFFER64COUNTER = UInt8[]
# const RANDNBUFFER64COUNTER = UInt8[]



function __init__()
    nthreads = Base.Threads.nthreads()
    nstreams = XREGISTERS * nthreads * W64
    GLOBAL_vRNGs[] = ptr = VectorizationBase.valloc(5nstreams + 256 * 3nthreads, UInt64)
    initXoshift!(ptr, nstreams)
    
    # resize!(RANDBUFFER32, 256nthreads)
    # resize!(RANDNBUFFER32, 256nthreads)
    # resize!(RANDBUFFER64, 256nthreads)
    # resize!(RANDNBUFFER64, 256nthreads)
    
    # resize!(RANDBUFFERCOUNTER, VectorizationBase.CACHELINE_SIZE*nthreads); fill!(RANDBUFFERCOUNTER, 0)
    # resize!(RANDNBUFFER32COUNTER, VectorizationBase.CACHELINE_SIZE*nthreads)
    # resize!(RANDBUFFER64COUNTER, VectorizationBase.CACHELINE_SIZE*nthreads)
    # resize!(RANDNBUFFER64COUNTER, VectorizationBase.CACHELINE_SIZE*nthreads)
end

    
end # module
