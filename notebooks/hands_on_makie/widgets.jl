module D
using JSServe

function WidgetContainer(title, widget; class="")
    return DOM.div(title, widget, class="flex-row, mb-1 mt-1 $class")
end

function Title(name; class="")
    return DOM.h2(name; class="font-semibold $class")
end

function Slider(name, values; class="")
    s = JSServe.Slider(values; class=class, style="width: 100%;")
    title = Title(DOM.div(name, DOM.div(s.value; class="float-right")))
    return s, WidgetContainer(title, s; class)
end

function Dropdown(name, values; class="")
    dd = JSServe.Dropdown(values)
    return dd, WidgetContainer(Title(name), dd; class)
end

function Checkbox(name, value; class="")
    c = JSServe.Checkbox(value)
    return c, WidgetContainer(Title(name), c; class)
end

function RowList(args...; class="")
    DOM.div(
        JSServe.TailwindCSS,
        args...,
        class="m-2 flex flex-row $class",
    )
end

function ColList(args...; class="")
    DOM.div(
        JSServe.TailwindCSS,
        args...,
        class="m-2 flex flex-col $class",
    )
end

function Card(content; class="")
    DOM.div(
        JSServe.TailwindCSS,
        content,
        class="rounded-md p-1 m-1 shadow $class",
    )
end

end
using ..D
