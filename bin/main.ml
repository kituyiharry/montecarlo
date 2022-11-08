(**
    Monte Carlo PI estimation
    @author: Harry K <kituyiharry@github.io>
*)

open Domainslib
open Stdlib

type point2d = { x: float; y: float};;

let origin    = { x = 0.; y = 0. }


let euclidean a a' =
    sqrt (((a'.x -. a.x)**2.) +. ((a'.y -. a.y)**2.))
;;

let quadsolve iterations hits =
  ((4. *. hits) /. Float.of_int iterations)

let randpoint _ = { x = (Random.float 1.); y = (Random.float 1.)  }

let estimate iters =
   Array.init iters (randpoint)
   |> Array.map (euclidean origin)
   |> Array.fold_left (+.) 0.
   |> quadsolve iters
;;

(*let fst p = p.x*)
(*let snd p = p.y*)

(* for point2d reductions when collapsed into the x param for 'a -> 'a *)
let (!+.) f g' = { x = f.x +. g'.x; y = 0. }

(* for 'a -> 'a cases, collapse result into x - see estimate_par *)
let euclidean2 a' =
  { x= sqrt (((a'.x -. origin.x)**2.) +. ((a'.y -. origin.y)**2.)); y = 0. }
;;

let idx = Array.unsafe_get
let isx = Array.unsafe_set

let estimate_par_reduce iters pool =
  let buff = Array.init iters (randpoint) in
  (
    let _ =
      Task.run pool
        (fun _ -> Task.parallel_for ~start:0 ~finish:(iters-1)
          ~body:(fun i -> (isx buff i (euclidean2 (idx buff i)))) pool)
    in
      Task.run pool
       (fun _ -> Task.parallel_for_reduce pool (!+.) (origin)
          ~start:0 ~finish:(iters-1) ~body:(idx buff))
  ).x
  |> quadsolve iters
;;

let estimate_par_scan iters pool =
  let buff = Array.init iters (randpoint) in
  (idx (
    let _ =
      Task.run pool
        (fun _ -> Task.parallel_for ~start:0 ~finish:(iters-1)
          ~body:(fun i -> (isx buff i (euclidean2 (idx buff i)))) pool)
    in
      Task.run pool
        (fun _ -> Task.parallel_scan pool (!+.) buff)
  ) (iters-1)).x
  |> quadsolve iters
;;


let timeonly f size =
  let t = Unix.gettimeofday () in
  let res = f () in
  Format.printf "Exec: %f seconds\tSize: %d\tRes: %f\t\n" (Unix.gettimeofday () -. t) (size) (res)
;;


let fmain upto =
  let rangevals = [|10;100;1000;10000;1000000;1234567;4999999;100000000;1000000000|] in

  Format.printf "\nSingle Thread\n\n";

  for i = 1 to upto do
    let size = rangevals.(i-1) in timeonly (fun _ -> estimate size) size
  done;

  let pool = Task.setup_pool ~num_domains:4 ~name:"MonteCarlo" () in

  Format.printf "\nMulti Thread SCAN\n\n";

  for i = 1 to upto do
    let size = rangevals.(i-1) in timeonly (fun _ -> estimate_par_scan size pool) size
  done;

  Format.printf "\nMulti Thread REDUCE\n\n";

  for i = 1 to upto do
    let size = rangevals.(i-1) in timeonly (fun _ -> estimate_par_reduce size pool) size
  done;

  Task.teardown_pool (pool)

let () = fmain 7
