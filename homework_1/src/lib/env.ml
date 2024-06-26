(* Variable identifiers are strings *)
type ide = string

(*
   An environment is a map from identifier to a value (what the identifier is bound to).
   For simplicity we represent the environment as an association list, i.e., a list of pair (identifier, data). 
*)
type 'v env = (ide * 'v * bool) list

(* To extend an environment *)
let extend (e : 'v env) (id : ide) (v : 'v) (t : bool) : 'v env =
  (id, v, t) :: e

(*
   Given an environment {env} and an identifier {x} it returns the data {x} is bound to.
  If there is no binding, it raises an exception.
*)
let rec lookup env x =
  match env with
  | [] -> failwith (x ^ " not found")
  | (y, v, _) :: r -> if x = y then v else lookup r x

(* Same as lookup, but returns the taintness boolean linked to the {x} identifier *)
let rec taint_lookup env x =
  match env with
  | [] -> failwith (x ^ " not found")
  | (y, _, t) :: r -> if x = y then t else taint_lookup r x

type trusted = ide list

(*Sublist of trusted that contains the identificators of secret variable or function*)
type secret = ide list

(*Sublist of trusted that contains the indentificators of the function defined
  as handle within a trustblock*)
type handled = ide list

type 'v secureTuple = trusted * secret * handled

let rec isIn (x : 'v) (l : 'v list) : bool =
  match l with
  | [] -> false
  | head :: tail -> if x = head then true else isIn x tail

let build (t : trusted) (s : secret) (h : handled) : 'v secureTuple =
  (t, s, h)

let getTrust (e : 'v secureTuple) : trusted =
  let trustedL, _, _ = e in
  trustedL

(*
   Get the gateways from a trusted environment.
*)
let getHandle (e : 'v secureTuple) : handled =
  let _, _, handle = e in
  handle

(*
   Get the secrets from a trusted environment.
*)
let getSecret (e : 'v secureTuple) : secret =
  let _, secr, _ = e in
  secr
