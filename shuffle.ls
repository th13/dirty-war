require! ramda: R

# Randomly shuffles an array.
shuffle = (arr, new-arr = []) ->
  | arr.length is 0 => new-arr
  | otherwise       => do
    idx = Math.floor <| Math.random! * arr.length
    shuffle (R.remove idx, 1, arr), (R.append arr[idx], new-arr)

module.exports = shuffle
