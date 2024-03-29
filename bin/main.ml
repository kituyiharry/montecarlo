(**
    Monte Carlo PI estimation
    @author: Harry K <kituyiharry@github.io>
*)

open Domainslib
open Stdlib

type point2d = { x: float; y: float};;

let origin   = { x = 0.; y = 0. }

let euclidean a a' =
    sqrt (((a'.x -. a.x)**2.) +. ((a'.y -. a.y)**2.))
;;

let quadsolve iterations hits =
  ((4. *. hits) /. Float.of_int iterations)
;;

let randpoint _ = { x = (Random.float 1.); y = (Random.float 1.)  }

let is_in_unit_circle x y = if (euclidean x y) <= 1. then 1. else 0.

(**
  Naive Single Threaded approach  
*)

let estimate_iterative iters =
  let hc = ref 0. in
  for _ = 1 to iters do
    hc := !hc +. (is_in_unit_circle origin (randpoint ()))
  done;
  !hc
  |> quadsolve iters
;;

let estimate_functional iters =
   Array.init iters (randpoint)
   |> Array.map (is_in_unit_circle origin)
   |> Array.fold_left (+.)  0.
   |> quadsolve iters
;;

let estimate_functional_lazy iters =
   Seq.init iters (fun _i -> randpoint ()) 
   |> Seq.map (is_in_unit_circle origin)
   |> Seq.fold_left (+.)  0.
   |> quadsolve iters
;;

(**
  Trivial parallelization approach  
*)

let estimate_par_for_reduce iters pool =
  (Task.run pool
    (fun _ ->
      Task.parallel_for_reduce
        ~start:0 ~finish:(iters-1)
        ~body:(fun _i -> is_in_unit_circle origin (randpoint ()))
        pool (+.) (0.)
    )
  )
  |> quadsolve iters
;;

(**
  Divide and Conquer approach  
*)

let handle_pi_work size receiver =
  let inscribed = 
    let acc = ref 0. in
    for _ = 1 to size do
      acc := !acc +. (is_in_unit_circle origin (randpoint ()))
    done;
    !acc in
  Chan.send receiver inscribed
;;

let rec spawn_workers num receiver size joined =
    match num with 
    | 0 -> joined 
    | n -> let send = Domain.spawn (
        fun _ -> handle_pi_work size receiver
      ) in
      spawn_workers (n - 1) receiver size (send :: joined)
;;

let estimate_via_chans doms iters =
  let chan = Chan.make_bounded doms in
  let work_per_core = iters/doms in
  let hitcount = ref 0. in
  (spawn_workers doms chan work_per_core [])
  |> (fun domains -> 
    for _ = 1 to doms do 
      let hits = Chan.recv chan in 
      hitcount := !hitcount +. hits
    done;
    domains)
  |> List.iter (Domain.join);
  (quadsolve iters !hitcount)
;;



let timeonly f size =
  let t = Unix.gettimeofday () in
  let res = f () in
  Format.printf "Exec: %f seconds\tSize: %d\tRes: %f\t\n" (Unix.gettimeofday () -. t) (size) (res)
;;

let next_rand_size multiple =
  Float.to_int (8. *. (Float.pow 8. multiple))

let fmain upto num_domains =

  Format.printf "num_domains: %d" num_domains;

 Format.printf "\nSingle Thread Functional\n\n";
 
  for i = 1 to upto do
    (*let size = rangevals.(i-1) in timeonly (fun _ -> estimate size) size*)
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_functional size) size
  done;

 Format.printf "\nSingle Thread Functional Lazy\n\n";

  for i = 1 to upto do
    (*let size = rangevals.(i-1) in timeonly (fun _ -> estimate size) size*)
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_functional_lazy size) size
  done;

 Format.printf "\nSingle Thread Iterative\n\n";

  for i = 1 to upto do
    (*let size = rangevals.(i-1) in timeonly (fun _ -> estimate size) size*)
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_iterative size) size
  done;

  let pool = Task.setup_pool ~num_domains:num_domains  ~name:"MonteCarlo" () in

  Format.printf "\nMulti Thread FOR_REDUCE\n\n";

  for i = 1 to upto do
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ -> estimate_par_for_reduce size pool) size
  done;


  Format.printf "\nMulti Thread DIVIDE_AND_CONQUER\n\n";

  for i = 1 to upto do
    let size = (next_rand_size (float_of_int i)) in timeonly (fun _ ->
      estimate_via_chans num_domains size) size
  done;

  Task.teardown_pool (pool);

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
