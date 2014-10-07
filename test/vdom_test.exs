defmodule VirtualDOMTest do
	use ExUnit.Case

	alias VirtualDOM, as: VDOM
	import VDOM, only: [diff: 2, tag: 1, tag: 2, tag: 3]
	alias VDOM.Node
	alias VDOM.Tag
	alias VDOM.Content

	test "nothing changed makes an empty diff" do
		assert diff("", "") == []
	end

	test "changing the content" do
		assert diff("", "fiz") == [{[0], Content, :update, "fiz"}]
	end

	test "changing nested content" do
		assert diff(tag(:span, do: [""]), tag(:span, do: ["fiz"])) == [{[0,0], Content, :update, "fiz"}]
	end

	test "inserting a node" do
		assert diff([], ["hi"]) == [{[-1], Node, :insert_after, %Content{content: "hi"}}]
	end

	test "removing a node" do
		assert diff(["hi"], []) == [{[0], Node, :remove, nil}]
	end

	test "changing an attribute" do
		assert diff(tag(:span, hi: :fiz), tag(:span, hi: :bar)) == [{[0], Tag, :update_attrs, [hi: :bar]}]
	end

	test "replacing a node" do
		assert diff(tag(:span), "hi") == [
			{[0], Node, :remove, nil},
			{[-1], Node, :insert_after, %Content{content: "hi"}}
		]
	end

	test "changing the name of a tag" do
		assert diff(tag(:span), tag(:div)) == [{[0], Tag, :update_name, :div}]
	end

	test "pretty much replacing a tag" do
		assert diff(
			tag(:span, font: "something") do[
				"fizbuz"
			]end,
			tag(:div, onclick: "alert('heyo!')") do[
				tag(:span) do[ "que say wha?" ]end
			]end
		) == [
			{[0], Tag, :update_name, :div},
			{[0], Tag, :update_attrs, [onclick: "alert('heyo!')"]},
			{[0, 0], Node, :remove, nil},
			{[0, -1], Node, :insert_after, tag(:span) do[ "que say wha?" ]end}
		]
	end
end