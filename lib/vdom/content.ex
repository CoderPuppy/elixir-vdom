defmodule VirtualDOM.Content do
	defstruct content: ""
end
defimpl VirtualDOM.Node, for: VirtualDOM.Content do
	
end
defimpl String.Chars, for: VirtualDOM.Content do
	def to_string(%VirtualDOM.Content{content: content}), do: content
end