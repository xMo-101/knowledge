#let get-auth-str(authors) = {
  let many = type(authors) == array and authors.len() > 1
  let auths-str = if type(authors) == str { authors } else { authors.join(", ") }

  return [#auths-str]
}
