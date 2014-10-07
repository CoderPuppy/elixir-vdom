defmodule VirtualDOM do
	alias VirtualDOM.Node
	alias VirtualDOM.Tag
	alias VirtualDOM.Content

	def tag(name, attrs \\ [], dol \\ []) do
		children = []
		if is_list(attrs[:do]) do
			children = attrs[:do]
			attrs = Dict.delete(attrs, :do)
		end
		if is_list(dol[:do]) do
			children = dol[:do]
		end
		children = unify(children)
		%Tag{name: name, attrs: attrs, children: children}
	end

	def nodify(content) when is_bitstring(content) or is_binary(content), do: %Content{content: content}
	def nodify(node = %Tag{}), do: node
	def nodify(node = %Content{}), do: node

	def unify(val), do: [val] |> List.flatten |> Enum.map(&nodify/1) |> List.flatten

	def diff(curr, new), do: Enum.reverse(diff_children(unify(curr), unify(new)))
	# do_diff([{
	# 	curr |> unify |> hd,
	# 	new |> unify |> hd,
	# 	[]
	# }], [])
	def do_diff([], patches), do: patches
	def do_diff([{node, node, _path} | queue], patches), do: do_diff(queue, patches)

	def do_diff([{%Content{content: _curr}, %Content{content: new}, path} | queue], patches) do
		do_diff(queue, [{Enum.reverse(path), Content, :update, new} |patches])
	end

	def do_diff([{
		curr_tag = %Tag{name: curr},
		new_tag = %Tag{name: new},
	path} | queue], patches) when curr != new do
		do_diff([{%{curr_tag | name: new}, new_tag, path} | queue], [{Enum.reverse(path), Tag, :update_name, new} |patches])
	end

	def do_diff([{
		curr_tag = %Tag{name: name, attrs: curr},
		new_tag = %Tag{name: name, attrs: new},
	path} | queue], patches) when curr != new do
		do_diff([{%{curr_tag | attrs: new}, new_tag, path} | queue], [{Enum.reverse(path), Tag, :update_attrs, new} |patches])
	end

	def do_diff([{
		%Tag{name: name, attrs: attrs, children: curr},
		%Tag{name: name, attrs: attrs, children: new},
	path} | queue], patches) when curr != new do
		do_diff(queue, diff_children(curr, new, 0, path, patches))
	end

	def do_diff([{_curr, new, path} | queue], patches) do
		do_diff(queue, [
			{Enum.reverse(prev(path)), Node, :insert_after, new},
			{Enum.reverse(path),       Node, :remove,       nil}
		|patches])
	end

	defp diff_children(curr, new, index \\ 0, path \\ [], patches \\ [])
	defp diff_children([], [], _index, _path, patches), do: patches
	defp diff_children([curr|rcurr], [new|rnew], index, path, patches) do
		diff_children(rcurr, rnew, index + 1, path, do_diff([{curr, new, [index|path]}], patches))
	end
	defp diff_children([_curr|rcurr], [], index, path, patches) do
		diff_children(rcurr, [], index + 1, path, [{[index | path], Node, :remove, nil} |patches])
	end
	defp diff_children([], [new|rnew], index, path, patches) do
		diff_children([], rnew, index + 1, path, [{[index - 1 | path], Node, :insert_after, new} |patches])
	end

	def prev([n|path]) when is_number(n), do: [n-1|path]
	def prev([]), do: []
end