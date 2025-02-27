#import "visualize.typ": *
#let _config-toml = toml("config.toml")
#let branches-of-tree(tree) = {
  let configs = ()
  for (key, value) in tree {
    if type(value) != dictionary {
      configs.push((key, value))
    } else {
        for val in branches-of-tree(value) {
          configs.push((key,..val))
        }
    }
  }
  return configs
}
#let text-dir() = {
  let dir = text.dir
  if dir != auto {return dir}
  if text.lang in (
    "ar", "dv", "fa", "he", "ks", "pa", "ps", "sd", "ug", "ur"
  ) {return rtl}
  return ltr
}
#let _config-to-state() = {
  let states = (:)
  for conf in branches-of-tree(_config-toml) {
    let value = conf.pop()
    // let key = conf.fold("", (folded, item) => {
    //   let sep ="."
    //   if folded == "" {sep = ""}
    //   folded + sep + item
    // })
    let key = conf.join(".")
    states.insert(key, state(key, value))
  }
  return states
}
#let states = _config-to-state()
#let config(..args) = {
  args = args.pos()
  if args.len() == 1 {
    return states.at(args.at(0)).get()
  }
  if args.len() == 2 {
    states.at(args.at(0)).update(args.at(1))
  }
}
#let parse-length(val) = {
  if type(val) == length {return val}

  let m = val.matches(regex("(\d+(?:\.\d+)?)(mm|cm|in|pt|em)"))

  assert(m.len() > 0, message: "no length found")
  assert(m.len() <= 1, message: "more than one length found")

  let (m,) = m

  let map = (
    "mm": 1mm,
    "cm": 1cm,
    "in": 1in,
    "pt": 1pt,
    "em": 1em,
  )

  map.at(m.captures.at(1)) * float(m.captures.at(0))
}
#let alphabetFa = (
  "آ",
  "ب",
  "پ",
  "ت",
  "ث",
  "ج",
  "چ",
  "ح",
  "خ",
  "د",
  "ذ",
  "ر",
  "ز",
  "ژ",
  "س",
  "ش",
  "ص",
  "ض",
  "ط",
  "ظ",
  "ع",
  "غ",
  "ف",
  "ق",
  "ک",
  "گ",
  "ل",
  "م",
  "ن",
  "و",
  "ه",
  "ی"
)
#let translate = (
  "en" : (
    "point": "point",
    "points": "points",
    "question": "question",
    "questions": "questions"
  ),
  "fa" : (
    "point": "نمره",
    "points": "نمره",
    "question": "پرسش",
    "questions": "پرسش"
  )
)
#let to-fa-digit(digit) = {
  show regex("\d"): y => str.from-unicode(str.to-unicode(y.text) + 1728)
  show regex("[.]"): str.from-unicode(1643)
  [#digit]
}
#let student = (
  firstname: none,
  lastname: none,
  number: none,
  grade: none,
  class: none
)
#let exam = (
  date: none,
  time: none,
  turn: none
)
#let question-points = state("question-points", 0)
#let question-counter = counter("question")
#let question-bonus-points = state("question-bonus-points", 0)
#let question-bonus-counter = counter("bonus-question")
#let _show-answers = state("show-answers", false)
#let show-answers(value) = {
  _show-answers.update(value) 
}
#let answer(body) = {
  context {
    set text(
      size: text.size * config("answer.font-scale"),
      fill: rgb(config("answer.color")),
    )
    if _show-answers.get() == true {body} else {hide[#body]}
  }
}
#let _label(value) = {
  context{
  let size = measure([ص\)])
  box(width: size.width)[
    #h(1fr)
    #box([#alphabetFa.at(value - 1)\)])
  ]
  }
}
#let question(point: none, level: none, bonus: false, border: none, breakable: none, source: none, body) = {
  if bonus == true {
    question-bonus-counter.step()
    question-bonus-points.update(p => p + point )
  } else {
    question-counter.step()
    question-points.update(p => p + point )
  }
  let number-rad = .65
  let level-rad = (.775, .90)
  let size = if level == none {number-rad * 2em} else {level-rad.at(1) * 2em}

  let quesNumber = box(
    height: size,
    width: size,
    inset: 0pt,
    context {
      let dx
      let dy
      if level == none {
        (dx, dy) = (0pt,0pt)
      } else {
        (dx, dy) = ((level-rad.at(1) - number-rad) * 1em, (level-rad.at(1) - number-rad) * 1em)
      }
      place(top + left, dx:dx, dy: dy,circle(radius: number-rad * 1em, stroke: .5pt, inset: 1pt, fill: blue.lighten(60%))[
        #set align(center + horizon)
        #if text.lang=="fa" {
          if bonus == true {
            to-fa-digit( question-bonus-counter.display())
          } else {
            to-fa-digit( question-counter.display())
          }
        } else {
          if bonus == true {
            question-bonus-counter.display()
          } else {
            question-counter.display()
          }
        }
      ])
      if level != none {
        let dx = level-rad.at(1)
        let dy = level-rad.at(1)
        let draw-level(start-deg, end-deg, filling) = {
          place(
            top + left,
            path(
              closed: true,
              fill: filling,
              stroke: .5pt + black,
              ..bezier-cubic(length: 1em, ..arc(..shift(dx: dx,dy: dy,
                (calc.cos(start-deg) * level-rad.at(0), calc.sin(start-deg) * level-rad.at(0)),
                (calc.cos(end-deg) * level-rad.at(0), calc.sin(end-deg) * level-rad.at(0)),
                (0,0)
              ))),
              ..bezier-cubic(length: 1em, ..arc(..shift(dx: dx,dy: dy,
                (calc.cos(end-deg) * level-rad.at(1), calc.sin(end-deg) * level-rad.at(1)),
                (calc.cos(start-deg) * level-rad.at(1), calc.sin(start-deg) * level-rad.at(1)),
                (0,0)
              ))),
          )
        )
      }   
        for i in range(5) {
          let startDeg = -96deg - i * 72deg
          let endDeg = -156deg - i * 72deg
          let filling
          if level != none and i < calc.trunc(level) {
            filling = black
          } else {
            filling = none
          }
          draw-level(startDeg, endDeg, filling)
        }
        if calc.fract(level) != 0 {
          let startDeg = -96deg - calc.trunc(level) * 72deg
          let endDeg = -96deg - calc.fract(level) * 60deg - calc.trunc(level) * 72deg
          let filling = black
          draw-level(startDeg, endDeg, filling)
        }
      }
    }
  )
  let quesPoint = box(
    stroke: none,
    inset: 4pt,
    [
      #context if text.lang=="fa" {to-fa-digit(point)} else {point}
      #context translate.at(text.lang).point
    ]
  )
  let quesWrap =  context[
    #let _border = border
    #if _border == none {
      _border = (
        paint: rgb(config("question.border.paint")),
        thickness: parse-length(config("question.border.thickness"))
      )
    }
    #block(
      width: 100%,
      radius: 5pt,
      inset: (bottom: 10pt, rest: 5pt),
      stroke: stroke(_border),
      spacing: .2em,
      breakable: {
        if breakable == none {config("question.breakable")} else {breakable}
      },
      [
          #let ques-number-size = measure(quesNumber)
          #let ques-point-size = measure(quesPoint)
          #let ques-number-point
          #let ques-number-point-size
          #if point !=none {
            ques-number-point = box(
              height: calc.max(ques-number-size.height, ques-point-size.height),
              inset: 0pt,
              stroke: stroke(thickness: .5pt, paint: blue),
              radius: calc.max(ques-number-size.height, ques-point-size.height) / 2 + 1pt,
              grid(columns:2, align: horizon + center, quesNumber, quesPoint)
            )
          } else {
            ques-number-point = [#quesNumber]
          }
          // ques-number-point-size = measure(ques-number-point)
          // v( -ques-number-point-size.height * .4)
          // box(move(dy: ques-number-point-size.height * .4, ques-number-point))
          #box(height: 1em, ques-number-point)
        #body
        #if source != none {
          parbreak()
          v(-.7em)
          h(1fr)
          text(size: .7em, source)
          v(-.5em)
        }
      ]
    )<question>
  ]
  [#quesWrap]
}
#let bonus-question = question.with(bonus: true)
#let part(colspan: 1, rowspan: 1, source: none, body) = {
  (colspan: colspan, rowspan: rowspan, source: source, body: body, type: "part")
}
#let hline(..args) = {
  args = args.named()
 (..args, type: "hline")
}
#let parts(columns: (1fr), labeling: _label, row-space: 1.2em, ..children) = {
  let children = children.pos()
  let part-num = 0
  if labeling == true {labeling = _label}
  for (index, child) in children.enumerate() {
    if type(child) == content {child = part(child)}
    if child.at("type") == "part" {
      let colspan = child.at("colspan")
      let rowspan = child.at("rowspan")
      let body = child.at("body")
      let source = child.at("source")
      if source != none {
        body = [#body #h(1fr) #text(size: .7em, source)]
      }
      // if type(labeling) == function { body = [#_label(part-num + 1)#h(.2em)#body] }
      if type(labeling) == function {
        body = grid(columns:(auto, 1fr),column-gutter: 2pt, box(baseline: 0em,labeling(part-num + 1)), body)
        // body = enum(number-align: start + horizon,enum.item(part-num)[#body])
        // body = [
        //   #box(_label(part-num))
        //   #box(fill: aqua)[#move(dy: 0em)[#body]]
        // ]
      }
      part-num += 1
      children.at(index) = grid.cell(colspan: colspan, rowspan: rowspan, inset:(top: 5pt), body)
    } else if child.at("type") == "hline" {
      child.remove("type")
      children.at(index) = grid.hline(..child)
    }
  }
  return grid(columns: columns, row-gutter: row-space - 5pt,..children)
}
#let true-sym = {
  box(width: .8em, height: .8em,{
    move(dy: 20%,{
      place(line(start: (0%, 0%), end: (100%, 100%)))
      place(line(start: (100%, 0%), end: (0%, 100%)))
    })
  })
}
#let checkbox(value) = {
  context {
    // let falseOpacity = 100%
    // let trueOpacity = 100%
    let show-answer = _show-answers.get()
    // if value == true and show-answer == true {
    //   falseOpacity = 100%
    //   trueOpacity = 0%
    // } else if value == false and show-answer == true {
    //   falseOpacity = 0%
    //   trueOpacity = 100%
    // }
    let color = rgb(config("answer.color"))
    let rad = .6em
    // let rel-points(..args) = {
    //   args = args.pos()
    //   for i in range(1, args.len()) {
    //       args.at(i).at(0) += args.at(i - 1).at(0)
    //       args.at(i).at(1) += args.at(i - 1).at(1)
    //   }
    //   args
    // }
    // let points = rel-points(
    //   (0cm, 0cm),
    //   (rad * 2 / 3, rad * 2 / 3),
    //   (3 / 2 * rad, -3 / 2 * rad),
    //   (- rad / 8, -rad / 8),
    //   (-11 / 8 * rad, 11 / 8 * rad),
    //   (-13 / 24 *rad, -13  / 24 * rad),
    // )
      let ch-box = box(width: 2 * rad, height: 2 * rad,{
        // let start-x = rad * calc.sqrt(2) / 2
        // let start-y = rad * calc.sqrt(2) / 2
        // let end-x = -start-x
        // let end-y = -start-y
        // let dx = rad
        // let dy = rad
        // place(
        //   top + left,
        //   dx: dx,
        //   dy: dy,
        //   line(
        //     stroke: rad / 6 + color.transparentize(falseOpacity),
        //     start: (start-x, start-y),
        //     end: (end-x, end-y),
        //   )
        // )
        // start-x = -start-x
        // end-x = -end-x
        // place(
        //   top + left,
        //   dx: dx,
        //   dy: dy,
        //   line(
        //     stroke: rad / 6 + color.transparentize(falseOpacity),
        //     start: (start-x, start-y),
        //     end: (end-x, end-y),
        //   )
        // )
        // place(
          // top + left,
          circle(radius: rad, stroke: .5pt)[
            #set align(horizon + center)
            #set text(fill: color)
            #if show-answer == true {
              if value == true {
                text(size: 1.6em, [✓])
              } else if value == false {
                text(size: 1.3em, [✗])
              }
            }
          ]
        // )
        // place(
        //   top + left,
        //   dx: .5 * rad,
        //   dy: .8 * rad,
        //   path(
        //     fill: color.transparentize(trueOpacity),
        //     closed: true,
        //     ..points,
        //   )
        // )
      })
      let ch-box-height = measure(ch-box).height
      box[
        #v(-.1 * ch-box-height)
        #move(dy: .3 * ch-box-height)[
          // #if text-dir() == ltr {h(.05em)} else {h(.1em)}
          #ch-box
          // #if text-dir() == ltr {h(.1em)} else {h(.05em)}
        ]
      ]
  }
}
#let tr(source: none, body) = {
  (true,body,source)
}
#let fa(source: none, body) = {
  (false,body,source)
}
#let pr(source: none, body) = {
  (none,body,source)
}
#let truefalse(columns: 1, labeling: true, row-space: 1.2em, ..props) = {
  let props = props.pos()
  props = props.enumerate().map((prop) => {
    let index = prop.at(0)
    let value = prop.at(1).at(0)
    let source = prop.at(1).at(2)
    let prop = prop.at(1).at(1)
    [
      #if labeling [#_label(index + 1)]
      #checkbox(value)
      #prop
      #if source != none {
          h(100fr)
          text(size: .7em, source)
        }
      #h(1fr)
    ]
  })
  grid(columns: columns, row-gutter: row-space,..props)
}
#let choice(body) = {
  (none,body)
}
#let true-choice(body) = {
  (true,body)
}
#let multiple-choice(columns: auto, labeling: _label, checkboxing: none, row-space: .5em, ..choices) = context{
  let choices = choices.pos()
  let columns = columns
  let checkboxing = checkboxing
  if labeling == true {labeling = _label}
  if columns == auto {columns = choices.len()}
  if checkboxing == none {checkboxing = config("multiple-choice.checkboxing")}
  choices = choices.enumerate().map((choice) => {
    let index = choice.at(0)
    let value = choice.at(1).at(0)
    let choice = choice.at(1).at(1)
    [
      #if type(labeling) == function {labeling(index + 1)}
      #if checkboxing {checkbox(value)}
      #choice
      #h(1fr)
    ]
  })
  grid(columns: columns, row-gutter: row-space,..choices)
}
#let _extract-length-answer(..args) = {
  args = args.pos()
  let leng = none
  let answer = none
  if args.at(0, default: none) == auto or  type(args.at(0, default: none)) == length {
    leng = args.at(0)
    answer = args.at(1, default: none)
  } else if args.at(1, default: none) == auto or  type(args.at(1, default: none)) == length {
    leng = args.at(1)
    answer = args.at(0,default: none)
  } else {
    answer = args.at(0,default: none)
  }
  return (leng, answer)
}
#let blank(..args, dash: "dotted") = {
  if dash == false {dash = none}
  if dash == true {dash = "dotted"}
  context {
    let length = auto
    let answer = none
    let answer-font-size = 1em * config("answer.font-scale")
    let answer-color = rgb(config("answer.color"))
    (length, answer) = _extract-length-answer(..args)
    let length-default = parse-length(config("blank.length"))
    if answer == none {
      if length == none or length == auto {
        length = length-default
      }
    } else {
      let answer-box = box(
        stroke: {
          if dash != none {
            (bottom: stroke(thickness: 1pt, dash: dash))
          } else {
            none
          }
        },
          align(center,[
          #set text(fill: answer-color, size: answer-font-size)
          #answer
        ])
      )
      if length == none {
        length = length-default
      } else if length == auto {
        length = measure(answer-box).width + .2em
      }
    }
    box(
      width: length,
      stroke: {
        if dash != none {
          (bottom: stroke(thickness: 1pt, dash: dash))
        } else {
          none
        }
      },
      align(center,[
        #set text(fill: answer-color, size: answer-font-size)
        #if _show-answers.get() == true {box(height: 0em, move(dy: -measure(answer).height, answer))} else {hide[#answer]}
      ])
    )
  }
}
#let blank-circle(..args) = {
  context{
    let length = none
    let answer = none
    let answer-font-size = text.size * config("answer.font-scale")
    let answer-color = rgb(config("answer.color"))
    (length, answer) = _extract-length-answer(..args)
    if length == none {
      length = parse-length(config("blank-circle.length"))
    }
    box(
      height: length / 2,
      move(
        dy: -length / 4,
        circle(radius: length / 2,stroke: .5pt,[
          #context{
            if _show-answers.get() == true {
              set text(
                size: text.size * config("answer.font-scale"),
                fill: answer-color,
              )
              set align(center + horizon)
              answer
            }
          }
        ])
      )
    )
  }
}
#let blank-square(..args) = {
  context{
    let length = none
    let answer = none
    let answer-font-size = text.size * config("answer.font-scale")
    let answer-color = rgb(config("answer.color"))
    (length, answer) = _extract-length-answer(..args)
    if length == none {
      length = parse-length(config("blank-square.length"))
    }
    box(
      baseline: length / 2 - .3em,
      rect(width: length, height: length,stroke: .5pt, [
        #context{
          if _show-answers.get() == true {
            set text(
              size: text.size * config("answer.font-scale"),
              fill: answer-color,
            )
            set align(center + horizon)
            answer
          }
        }
      ])
    )
  }
}
#let pair(..args) = {
  args = args.pos()
  (args.at(0), args.at(1), args.at(2))
}
#let _itembox(item) = {
  if item != none {
    let itembox = box(
      inset:5pt,
      stroke: 1pt + blue,
      radius: 3pt,
      item
    )
    let itembox-size = measure(itembox)
    let (itembox-width, itembox-height) = (itembox-size.width, itembox-size.height)
    return (itembox, itembox-width, itembox-height)
  }
  return (none, 0pt, 0pt)
}
#let matching(..children) = {
  children = children.pos()
  let ques-children = children.map(item => {
    item.slice(0,1)
  })
  let answer-children = children.sorted(key: t => t.at(2)).map(item => {
    item.slice(1,2)
  })
  let pairs = children.enumerate().map(item => {
    (..item.at(1),item.at(0))
  }).sorted(key: t => t.at(2)).enumerate().map(item => {
    (item.at(1).at(3), item.at(0))
  })
  let pairs-edited = pairs
  for index in range(pairs.len()) {
    if ques-children.at(pairs.at(index).at(0)).at(0) == none {
      pairs-edited.at(index) = (none, pairs-edited.at(index).at(1))
      for j in range(pairs.len()) {
        if pairs.at(j).at(0) > pairs.at(index).at(0) {
          pairs-edited.at(j) = (pairs-edited.at(j).at(0) - 1, pairs-edited.at(j).at(1))
        }
      }
    }
    if answer-children.at(pairs.at(index).at(1)).at(0) == none {
      pairs-edited.at(index) = (pairs-edited.at(index).at(0), none)
      for j in range(pairs.len()) {
        if pairs.at(j).at(1) > pairs.at(index).at(1) {
          pairs-edited.at(j) = (pairs-edited.at(j).at(0), pairs-edited.at(j).at(1) - 1)
        }
      }
    }
  }  
  context{
    let column-space = 2cm
    let row-space = .5em
    let qbox-extra-space = 0pt
    let abox-extra-space = 0pt
    let qbox = ()
    let abox = ()
    let qbox-height = 0pt
    let abox-height = 0pt
    let qbox-width = 0pt
    let abox-width = 0pt
    let bullet-space = 3pt
    let bullet-radius = 2pt
    for index in range(children.len()) {

      let _itembox-details = _itembox(ques-children.at(index).at(0))
      if _itembox-details.at(0) != none {
        let (_itembox, _itembox-width, _itembox-height) = _itembox-details
        if _itembox-width > qbox-width {qbox-width = _itembox-width}
          qbox-height += _itembox-height
          qbox.push( (_itembox, _itembox-width, _itembox-height) )
      }

      let _itembox-details = _itembox(answer-children.at(index).at(0))
      if _itembox-details.at(0) != none {
        let (_itembox, _itembox-width, _itembox-height) = _itembox-details
        if _itembox-width > abox-width {abox-width = _itembox-width}
          abox-height += _itembox-height
          abox.push( (_itembox, _itembox-width, _itembox-height) )
      }

    }
    qbox-height += ((qbox.len() - 1) * row-space)
    abox-height += ((abox.len() - 1) * row-space)
    if qbox-height.to-absolute() > abox-height.to-absolute() {
      abox-extra-space = (qbox-height - abox-height) / (abox.len() - 1)
    } else if abox-height.to-absolute() > qbox-height.to-absolute() {
      qbox-extra-space = (abox-height - qbox-height) / (qbox.len() - 1)
    }

    let qbox-items = ()
    for index in range(qbox.len()) {
      let dx = qbox-width - qbox.at(index).at(1)
      let dy = 0pt
      for j in range(index) {
        dy += qbox.at(j).at(2)
      }
      dy += (index * (row-space + qbox-extra-space))
      let bullet-dx = dx + qbox.at(index).at(1) + bullet-space
      let bullet-dy = dy + qbox.at(index).at(2) / 2 - bullet-radius
      let bullet-center-dy = bullet-dy + bullet-radius
      let bullet-center-dx = bullet-dx + bullet-radius
      if text-dir() == rtl {
        dx = -dx
        bullet-dx = -bullet-dx
        bullet-center-dx = -bullet-center-dx
      }
      qbox-items.push((
        dx: dx,
        dy: dy,
        bullet-dx: bullet-dx,
        bullet-dy: bullet-dy,
        bullet-center-dy: bullet-center-dy,
        bullet-center-dx: bullet-center-dx,
        item: qbox.at(index).at(0)
      ))
    }

    let abox-items = ()
    for index in range(abox.len()) {
      let dx = qbox-width + column-space
      let dy = 0pt
      for j in range(index) {
        dy += abox.at(j).at(2)
      }
      dy += (index * (row-space + abox-extra-space))
      let bullet-dx = dx - bullet-space - 2 * bullet-radius
      let bullet-dy = dy + abox.at(index).at(2) / 2 - bullet-radius
      let bullet-center-dy = bullet-dy + bullet-radius
      let bullet-center-dx = bullet-dx + bullet-radius
      if text-dir() == rtl {
        dx = -dx
        bullet-dx = -bullet-dx
        bullet-center-dx = -bullet-center-dx
      }
      abox-items.push((
        dx: dx,
        dy: dy,
        bullet-dx: bullet-dx,
        bullet-dy: bullet-dy,
        bullet-center-dy: bullet-center-dy,
        bullet-center-dx: bullet-center-dx,
        item: abox.at(index).at(0)
      ))      
    }
    let connect-items(q, a) = {
      if q == none or a == none {return none}
      place(
        line(
          stroke: 1pt + rgb(config("answer.color")),
          start: (qbox-items.at(q).bullet-center-dx, qbox-items.at(q).bullet-center-dy),
          end: (abox-items.at(a).bullet-center-dx, abox-items.at(a).bullet-center-dy),
        )
      )
    }
    block(
      height: calc.max(qbox-height.to-absolute(), abox-height.to-absolute()),
      breakable: false,
      width: qbox-width + column-space + abox-width,
      {
        for item in qbox-items {
          place(dx: item.dx, dy: item.dy, item.item)
          place(
            dx: item.bullet-dx,
            dy: item.bullet-dy,
            box[#circle(fill: rgb(config("answer.color")), radius: bullet-radius)]
          )
        }
        for item in abox-items {
          place(dx: item.dx, dy: item.dy, item.item)
          place(
            dx: item.bullet-dx,
            dy: item.bullet-dy,
            box[#circle(fill: rgb(config("answer.color")), radius: bullet-radius)]
          )
        }
        if _show-answers.get() == true {
          for pair in pairs-edited {
            connect-items(pair.at(0), pair.at(1))
          }
        }
      }
    )
  }
}