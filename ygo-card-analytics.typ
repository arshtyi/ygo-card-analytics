#import "@preview/lilaq:0.6.0" as lq

#let title = "Yu-Gi-Oh! Card Analytics"
#let author = "arshtyi"
#let date = datetime.today()
#let description = "Analyze Yu-Gi-Oh! cards in Typst"

#set document(title: title, author: author, date: date, description: description)
#set page(paper: "a4")
#set text(
    font: ((name: "Lato", covers: "latin-in-cjk"), "Noto Serif CJK SC", "Noto Sans CJK SC"),
    lang: "zh",
    region: "cn",
)
#page(align(right + horizon)[
    #block(below: 1em, text(size: 32pt, strong(title)))
    #set text(size: 15pt)
    #description
    #v(1em)
    #author\
    #datetime.today().display("[year]-[month]-[day]")
])
#counter(page).update(1)
#page(
    footer: {
        line(length: 100%)
        v(-.5em)
        align(right)[#context counter(page).display("i")]
    },
    {
        set outline.entry(fill: repeat(gap: .15em, move(dy: -.25em)[.]))
        outline(title: "Contents")
    },
)
#counter(page).update(1)
#set page(footer: {
    line(length: 100%)
    v(-.5em)
    grid(
        columns: (1fr, 1fr),
        align: (left, right),
        context counter(page).display("1"),
        context {
            let headings = query(
                selector(heading.where(level: 1)).before(here()),
            )
            if headings.len() > 0 {
                let head = headings.last()
                counter(heading).display(head.numbering, at: head.location())
                h(.5em)
                head.body
            }
        },
    )
})
#set heading(numbering: "1.1.1.1.")
#show heading.where(level: 1): head => {
    pagebreak()
    align(right)[#block(below: 2em)[Chapter #context counter(heading).get().first()\ #text(size: 30pt, head.body)]]
}
#show link: it => underline(offset: 2.5pt, stroke: 1.5pt, it)
#let lq-diagram(labels, values, width: 0% + 12cm, height: 0% + 6cm) = figure(lq.diagram(
    margin: (x: 1%, y: 1%),
    grid: none,
    width: width,
    height: height,
    xaxis: (ticks: labels.enumerate(), subticks: none),
    yaxis: (ticks: none),
    ylim: (0, calc.max(..values) * 1.2),
    lq.bar(range(labels.len()), values),
    ..range(labels.len())
        .zip(values)
        .map(((x, y)) => lq.place(
            x,
            y,
            align: bottom,
            pad(.5em, text(10pt)[#y]),
        )),
))
#let lq-hdiagram(labels, values, width: 0% + 12cm, height: 0% + 6cm, margin: (x: 0%, y: 6%)) = figure(lq.diagram(
    margin: margin,
    grid: none,
    width: width,
    height: height,
    yaxis: (ticks: labels.enumerate(), subticks: none),
    xaxis: (ticks: none),
    xlim: (0, calc.max(..values) * 1.2),
    lq.hbar(values, range(labels.len())),
    ..values
        .zip(range(labels.len()))
        .map(((x, y)) => lq.place(
            x,
            y,
            align: left,
            pad(.5em, text(10pt)[#x]),
        )),
))

= 说明

数据来自#link("https://github.com/arshtyi/ygo-cards")[arshtyi/ygo-cards]，hash：

#figure(table(
    columns: 2,
    [OCG & TCG], read("assets/ot.json.sha256sum").slice(0, 64),
    [Rush Duel], read("assets/rd.json.sha256sum").slice(0, 64),
))

= OCG & TCG

== 总览

#let ot-json = json("assets/ot.json")

共#ot-json.len()张

=== 分类

#let labels = ("怪兽", "魔法", "陷阱")
#let values = labels.map(type => ot-json.filter(card => card.type.contains(type)).len())
#lq-diagram(labels, values)

=== 异画

#let labels = ("原画", "异画")
#let values = (
    labels
        .enumerate()
        .map(((i, _)) => (
            ot-json.map(card => int(card.alias != 0)).filter(card => card == i)
        ).len())
)
#lq-diagram(labels, values)

=== 禁限

==== OCG

#let labels = ("禁止", "限制", "准限制")
#let values = labels.enumerate().map(((i, _)) => (ot-json.map(card => card.lf.at(0)).filter(card => card == i)).len())
#lq-diagram(labels, values)

==== TCG

#let values = labels.enumerate().map(((i, _)) => (ot-json.map(card => card.lf.at(1)).filter(card => card == i)).len())
#lq-diagram(labels, values)

=== 卡名长

#let (labels, values) = {
    let kvs = (:)
    for card in ot-json {
        let key = str(card.name.len())
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 20cm)

== 怪兽

#let monsters = ot-json.filter(card => card.type.contains("怪兽"))

共#monsters.len()张

=== 衍生物

#let labels = ("衍生物", "非衍生物")
#let values = (
    labels
        .enumerate()
        .map(((idx, _)) => (
            monsters.map(monster => int(not monster.type.contains("衍生物"))).filter(type => type == idx)
        ).len())
)
#lq-diagram(labels, values)

=== 通常

#let labels = ("通常", "效果", "均不是")
#let values = {
    let subvalues = labels
        .filter(type => type != "均不是")
        .map(type => monsters.filter(monster => monster.type.contains(type)).len())
    subvalues + (monsters.len() - subvalues.sum(),)
}
#lq-diagram(labels, values)

=== 召唤法

#let labels = ("仪式", "融合", "同调", "超量", "灵摆", "连接", "其他")
#let values = {
    let subvalues = labels
        .filter(type => type != "其他")
        .map(type => monsters.filter(card => card.type.contains(type)).len())
    subvalues + (monsters.len() - subvalues.sum(),)
}
#lq-diagram(labels, values)

=== 种族

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = monster.type.at(1)
        if key != "衍生物" { kvs.insert(key, kvs.at(key, default: 0) + 1) }
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 18cm)

=== 其他

#let rhs = ("", "效果", "通常", "仪式", "融合", "同调", "超量", "灵摆", "连接", "特殊召唤", "衍生物")
#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = monster.type.at(2)
        if key in rhs { key = monster.type.at(3, default: "") }
        if key not in rhs { kvs.insert(key, kvs.at(key, default: 0) + 1) }
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a >= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

=== 属性

#let labels = ("神", "光", "暗", "风", "地", "炎", "水")
#let values = labels.enumerate().map(((i, _)) => (monsters.filter(monster => monster.attribute == i)).len())
#lq-diagram(labels, values)

=== 等级

#let labels = range(1, 14).rev().map(str)
#let values = labels.map(level => monsters
    .filter(monster => "level" in monster)
    .filter(monster => monster.level == int(level))
    .len())
#lq-hdiagram(labels, values)

=== 阶级

#let labels = range(1, 14).rev().map(str)
#let values = labels.map(rank => monsters
    .filter(monster => "rank" in monster)
    .filter(monster => monster.rank == int(rank))
    .len())
#lq-hdiagram(labels, values)

=== 灵摆刻度

#let labels = range(0, 15).map(str)
#let values = labels.map(scale => monsters
    .filter(monster => "pendulumScale" in monster)
    .filter(monster => monster.pendulumScale == int(scale))
    .len())
#lq-diagram(labels, values)

=== 链接值

#let labels = range(1, 9).map(str)
#let values = labels.map(value => monsters
    .filter(monster => "linkValue" in monster)
    .filter(monster => monster.linkValue == int(value))
    .len())
#lq-diagram(labels, values)

=== 链接箭头

#let labels = ("左上", "左", "左下", "下", "右下", "右", "右上", "上")
#let values = (
    labels
        .enumerate()
        .map(((i, _)) => (
            monsters.filter(monster => "linkMarker" in monster).filter(monster => i in monster.linkMarker)
        ).len())
)
#lq-diagram(labels, values)

== 魔法

#let spells = ot-json.filter(card => card.type.contains("魔法"))

共#spells.len()张

=== 类型

#let (labels, values) = {
    let kvs = (:)
    for spell in spells {
        let key = spell.type.at(1, default: "通常")
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

== 陷阱

#let traps = ot-json.filter(card => card.type.contains("陷阱"))

共#traps.len()张

=== 类型

#let (labels, values) = {
    let kvs = (:)
    for trap in traps {
        let key = trap.type.at(1, default: "通常")
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

= Rush Duel

== 总览

#let rd-json = json("assets/rd.json")

共#rd-json.len()张

=== 分类

#let labels = ("怪兽", "魔法", "陷阱")
#let values = labels.map(type => rd-json.filter(card => card.type.contains(type)).len())
#lq-diagram(labels, values)

=== 异画

#let labels = ("原画", "异画")
#let values = (
    labels
        .enumerate()
        .map(((i, _)) => (
            rd-json.map(card => int(card.alias != 0)).filter(card => card == i)
        ).len())
)
#lq-diagram(labels, values)

=== 禁限

#let labels = ("禁止", "限制", "准限制")
#let values = labels.enumerate().map(((i, _)) => (rd-json.map(card => card.lf).filter(card => card == i)).len())
#lq-diagram(labels, values)

=== 卡名长

#let (labels, values) = {
    let kvs = (:)
    for card in rd-json {
        let key = str(card.name.len())
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 16cm)

== 怪兽

#let monsters = rd-json.filter(card => card.type.contains("怪兽"))

共#monsters.len()张

=== 通常

#let labels = ("通常", "效果", "均不是")
#let values = {
    let subvalues = labels
        .filter(type => type != "均不是")
        .map(type => monsters.filter(monster => monster.type.contains(type)).len())
    subvalues + (monsters.len() - subvalues.sum(),)
}
#lq-diagram(labels, values)

=== 召唤法

#let labels = ("仪式", "融合", "其他")
#let values = {
    let subvalues = labels
        .filter(type => type != "其他")
        .map(type => monsters.filter(card => card.type.contains(type)).len())
    subvalues + (monsters.len() - subvalues.sum(),)
}
#lq-diagram(labels, values)

=== 种族

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = monster.type.at(1)
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 18cm)

=== 其他

#let rhs = ("", "效果", "通常", "仪式", "融合")
#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = monster.type.at(2)
        if key not in rhs { kvs.insert(key, kvs.at(key, default: 0) + 1) }
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a >= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

=== 属性

#let labels = ("光", "暗", "风", "地", "炎", "水")
#let values = labels.enumerate().map(((i, _)) => (monsters.filter(monster => monster.attribute == i)).len())
#lq-diagram(labels, values)

=== 等级

#let labels = range(1, 14).rev().map(str)
#let values = labels.map(level => monsters
    .filter(monster => "level" in monster)
    .filter(monster => monster.level == int(level))
    .len())
#lq-hdiagram(labels, values)

== 魔法

#let spells = rd-json.filter(card => card.type.contains("魔法"))

共#spells.len()张

=== 类型

#let (labels, values) = {
    let kvs = (:)
    for spell in spells {
        let key = spell.type.at(1, default: "通常")
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

== 陷阱

#let traps = rd-json.filter(card => card.type.contains("陷阱"))

共#traps.len()张

=== 类型

#let (labels, values) = {
    let kvs = (:)
    for trap in traps {
        let key = trap.type.at(1, default: "通常")
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    (kvs.keys(), kvs.values())
}
#lq-diagram(labels, values)

= Appendix

这部分图太大，页面尺寸自适应

== OCG & TCG

#let ot-json = json("assets/ot.json")

#show heading.where(level: 3): head => {
    pagebreak()
    head
}
#set page(footer: none, width: auto, height: auto)

=== 异画

#let (labels, values) = {
    let kvs = (:)
    for card in ot-json {
        let key = if card.alias != 0 and not card.type.contains("衍生物") { str(card.alias) } else { continue }
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (
        kvs.keys().map(id => ot-json.find(card => card.id == int(id)).name),
        kvs.values(),
    )
}
#lq-hdiagram(labels, values, height: 140cm, width: 20cm, margin: (x: 0%, y: 0%))

=== 效果文本长

#let (labels, values) = {
    let kvs = (:)
    for card in ot-json {
        let key = str(card.description.len())
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 180cm, width: 20cm, margin: (x: 0%, y: 0%))

#let monsters = ot-json.filter(card => card.type.contains("怪兽"))

=== 攻击力

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = str(monster.atk)
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 30cm, width: 20cm, margin: (x: 0%, y: 1%))

=== 守备力

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = if "def" in monster { str(monster.def) } else { continue }
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 30cm, margin: (x: 0%, y: 1%))

=== 灵摆效果文本长

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = if "pendulumDescription" in monster { str(monster.pendulumDescription.len()) } else { continue }
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 80cm, margin: (x: 0%, y: 0%))

== Rush Duel

#let rd-json = json("assets/rd.json")

=== 异画

#let (labels, values) = {
    let kvs = (:)
    for card in rd-json {
        let key = if card.alias != 0 { str(card.alias) } else { continue }
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys().map(id => rd-json.find(card => card.id == int(id)).name), kvs.values())
}
#lq-hdiagram(labels, values, height: 80cm, width: 16cm, margin: (x: 0%, y: 0%))

=== 效果文本长

#let (labels, values) = {
    let kvs = (:)
    for card in rd-json {
        let key = str(card.description.len())
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 160cm, width: 16cm, margin: (x: 0%, y: 0%))

#let monsters = rd-json.filter(card => card.type.contains("怪兽"))

=== 攻击力

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = str(monster.atk)
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 20cm, width: 16cm, margin: (x: 0%, y: 0%))

=== 守备力

#let (labels, values) = {
    let kvs = (:)
    for monster in monsters {
        let key = str(monster.def)
        kvs.insert(key, kvs.at(key, default: 0) + 1)
    }
    let kvs = kvs.pairs().sorted(key: pair => pair.at(1), by: (a, b) => a <= b).to-dict()
    (kvs.keys(), kvs.values())
}
#lq-hdiagram(labels, values, height: 20cm, width: 16cm, margin: (x: 0%, y: 0%))
