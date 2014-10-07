defmodule VirtualDOM.Tag do
	defstruct name: nil, attrs: %{}, children: []
end
defimpl VirtualDOM.Node, for: VirtualDOM.Tag do

end
defimpl String.Chars, for: VirtualDOM.Tag do
	def to_string(%VirtualDOM.Tag{name: name, attrs: attrs, children: children}) do
		attrs_str = attrs
			|> Enum.map(&(" #{&1}=\"#{&2}\""))
		children_str = children
			|> Enum.map(&String.Chars.to_string/1)
			|> Enum.map(&(&1
				|> String.split(~r/[\r\n]/u)
				|> Enum.map(fn line -> "\t#{line}" end)
				|> Enum.join("\n")
			))
		"<#{name}#{attrs_str}>\n#{children_str}\n</#{name}>"
	end
end