(**
    Monte Carlo PI estimation
    @author: Harry K <kituyiharry@github.io>
*)

open Domainslib
open Stdlib

type point2d = { mutable x: float; y: float};;

let origin   = { x = 0.; y = 0. }


let euclidean a a' =
    sqrt (((a'.x -. a.x)**2.) +. ((a'.y -. a.y)**2.))
;;

let quadsolve iterations hits =
  ((4. *. hits) /. Float.of_int iterations)
;;

let randpoint _ = { x = (Random.float 1.); y = (Random.float 1.)  }

let estimate iters =
   Array.init iters (randpoint)
   |> Array.map (euclidean origin)
   |> Array.fold_left (+.) 0.
   |> quadsolve iters
;;

(*let fst p = p.x*)
(*let snd p = p.y*)
let idx = Array.unsafe_get
(*let isx = Aray.unsafe_set*)

(* for point2d reductions when collapsed into the x param for 'a -> 'a *)
let (!+.) f g' = { x = f.x +. g'.x; y = 0. }

(* for point2d reductions with side effects *)
(*let (!<-.) f g' = f.x <- (f.x +. g'.x); f*)

(* for 'a -> 'a cases, collapse result into x - see estimate_par_* *)
(*let euclidean2 a' =*)
  (*a'.x <- sqrt (((a'.x -. origin.x)**2.) +. ((a'.y -. origin.y)**2.));*)
  (*(*a'*)*)
(*;;*)

let specificeuclidean buff i =
  let a' = idx buff i in
  a'.x <- sqrt (((a'.x -. origin.x)**2.) +. ((a'.y -. origin.y)**2.));
;;

(* for 'a -> 'a -> 'a cases, collapse result into x - see estimate_par_join *)
let muta_euclidean a a' =
  a.x <- (a.x +. sqrt (((a'.x -. origin.x)**2.) +. ((a'.y -. origin.y)**2.)));
  a
;;


let estimate_par_reduce iters pool =
  let buff = Array.init iters (randpoint) in
  (
    let _ =
      Task.run pool
        (fun _ -> Task.parallel_for ~start:0 ~finish:(iters-1)
          (*~body:(fun i -> (isx buff i (euclidean2 (idx buff i)))) pool)*)
          ~body:(specificeuclidean buff) pool)
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
          (*~body:(fun i -> (isx buff i (euclidean2 (idx buff i)))) pool)*)
          ~body:(specificeuclidean buff) pool)
    in
      Task.run pool
        (fun _ -> Task.parallel_scan pool (!+.) buff)
  ) (iters-1)).x
  |> quadsolve iters
;;

let estimate_par_join_scan iters pool =
  let buff = Array.init iters (randpoint) in
  (idx (
      Task.run pool
        (fun _ -> Task.parallel_scan pool (muta_euclidean) buff)
  ) (iters-1)).x
  |> quadsolve iters
;;


let timeonly f size =
  let t = Unix.gettimeofday () in
  let res = f () in
  Format.printf "Exec: %f seconds\tSize: %d\tRes: %f\t\n" (Unix.gettimeofday () -. t) (size) (res)
;;

let next_rand_size multiple =
  Float.to_int ((Random.float 1.) *. (Float.pow 10. multiple))

let fmain upto num_domains =

  (*let rangevals = [|31;314;3141;31415;3141592;31415926;314159265;3141592653|] in*)

  Format.printf "num_domains: %d" num_domains;

  Format.printf "\nSingle Thread\n\n";

  for i = 1 to upto do
    (*let size = rangevals.(i-1) in timeonly (fun _ -> estimate size) size*)
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate size) size
  done;

  let pool = Task.setup_pool ~num_domains:num_domains  ~name:"MonteCarlo" () in

  Format.printf "\nMulti Thread SCAN\n\n";

  for i = 1 to upto do
   let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_par_scan size pool) size
  done;

  Format.printf "\nMulti Thread REDUCE\n\n";
  (* Most stable *)
  for i = 1 to upto do
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_par_reduce size pool) size
  done;

  Format.printf "\nMulti Thread JOINSCAN\n\n";

  for i = 1 to upto do
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_par_join_scan size pool) size
  done;

  Task.teardown_pool (pool)

;;

let () =
  (* Read number of domains from Environment *)
  match Sys.getenv_opt "NDOMS" with
  | Some v ->
      ( match int_of_string_opt v with
      | Some d -> fmain 8 d
      | _ -> fmain 8 8 )
  | _ -> fmain 8 8
;;
