// LTeX: language=en
#import "utils.typ": *

#let knowledge(
  // The language of the work.
  // NOTE: If you change this consider changing also the following
  // parameters and set them into the language of your choice:
  //  - pre-authors
  //  - pre-professors
  //  - top-sec-name
  language: "en",
  // The title of the work.
  title: [Title],
  subtitle: [Subtitle],
  // The authors of the work. This should be an array (also if there is just one).
  authors: ("Person 1",),
  // The date of the work. Set to none to disable.
  date: "Year/none",
  // The typographic name of the level 1 section.
  // TODO: Check the language dependency.
  top-section-name: "Chapter",
  // The image to insert in the first page. Set to none to disable.
  // This should be an image object.
  front-image: none,
  // The preface of the notes. Set to none to disable.
  preface: none,
  // The table of contents function. Set to none to disable.
  table-of-contents: outline(),
  // The appendix
  appendix: (
    enabled: false,
    title: "",
    body: none,
  ),
  // The bibliography.
  // Should be a call to `bibliography` (e.g. `bibliography("refs.bib")`) or `none`
  bib: none,
  // The content of the work
  body,
) = {
  set document(title: title, author: authors)
  set text(font: "Open Sans", size: 11pt, lang: language)
  set page(paper: "a4", margin: auto)

  // Front page
  page(
    align(
      center + horizon,
      block(width: 90%)[
        #line(length: 110%, stroke: 2pt + black) // top line
        #let v-space = v(2em, weak: true)

        #text(3em)[*#title*]

        #v-space

        #text(2em)[#subtitle]

        #v-space

        #text(1.5em)[#get-auth-str(authors)]\

        #if date != none {
          v-space
          text(1.2em, date)
        }

        #if front-image != none {
          v-space
          front-image
        }

        #v-space
        #line(length: 110%, stroke: 2pt + black) // bottom line
      ],
    ),
  )

  // Paragraph settings
  set par(justify: true)
  show link: it => {
    if type(it.dest) != str { it } else {
      set text(blue)
      underline(it)
    }
  }

  // Preface page settings
  set page(numbering: "i")

  // Preface
  if preface != none {
    page[
      #set text(style: "italic")
      #preface
    ]
  }

  // Table of contents
  if table-of-contents != none {
    table-of-contents
  }

  // Normal page settings
  set page(
    header: context {
      let phys-page = here().page()
      let is-odd = calc.odd(phys-page)
      let alignment = if is-odd { right } else { left }

      // NOTE: If there are also parts level should be 2
      let chapter-heading = heading.where(level: 1)

      // Using only the page where there are chapter headings
      if query(chapter-heading).any(item => item.location().page() == phys-page) { return }

      // Find the chapter of the section we are currently in.
      let chapter-before = query(chapter-heading.before(here()))
      if chapter-before.len() > 0 {
        let current-chapter = chapter-before.last()
        let chapter-title = upper(current-chapter.body)
        let chapter-number = counter(chapter-heading).display()
        let chapter-string = [#chapter-number #chapter-title]
        if chapter-number != none {
          align(alignment, text(size: 0.75em, chapter-string))
        }
      }
    },
    numbering: "1",
  )
  // Reset page numbering
  counter(page).update(1)

  // Per chapter equations
  set math.equation(numbering: item => {
    let chapter-count = counter(heading).get().first()
    numbering("(1.1)", chapter-count, item)
  })

  // Break large tables across pages.
  show figure.where(kind: table): set block(breakable: true)
  set table(
    inset: 7pt, // default is 5pt
    stroke: (0.5pt + luma(200)),
  )
  // show table.cell.where(y: 0): text.with(weight: 700) // Use smallcaps for table header row.

  show table.cell.where(y:0): smallcaps
  show table.cell.where(y:0): text.with(font:"Montserrat", weight:700)

  // Body. Wrapped so set rules apply only to it
  {
    set heading(numbering: "1.")
    // TODO: Finish
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      counter(math.equation).update(0)
      let header = smallcaps[#top-section-name #counter(heading).display("1")]
      [
        #text(1em, header, font: "Montserrat")
        #v(1em, weak: true)
        #text(1.4em)[#it.body]
        #v(1.5em, weak: true)
      ]
    }
    body
  }

  // Appendix
  if appendix.enabled {
    pagebreak()
    heading(level: 1)[
      #smallcaps[#appendix.at("title", default: "Appendix")]
    ]

    // For heading prefixes in the appendix, the standard convention is A.1.1.
    let num-fmt = "A.1.1."

    counter(heading).update(0)
    set heading(
      outlined: false,
      numbering: (..nums) => {
        let vals = nums.pos()
        if vals.len() > 0 {
          let v = vals.slice(0)
          return numbering(num-fmt, ..v)
        }
      },
    )
    appendix.body
  }

  // Bibliography.
  if bib != none {
    pagebreak()
    show bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bib
  }
}
