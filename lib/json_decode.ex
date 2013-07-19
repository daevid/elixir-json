defmodule JSON.Decode do

  #32 = ascii space, cleaner than using "? ", I think
  @acii_space 32

  defexception UnexpectedTokenError, token: nil do
    def message(exception) do
      "Invalid JSON - unexpected token >>#{exception.token}<<"
    end
  end
  
  defexception UnexpectedEndOfBufferError, message: "Invalid JSON - unexpected end of buffer"
  
  def from_json("[]") do 
    []
  end

  def from_json("{}") do 
    HashDict.new
  end

  def from_json(bitstring) when is_bitstring(bitstring) do
    accept_root(bitstring)
  end

  #Accepts anything considered a root token (object or array for now)
  defp accept_root(bitstring) do
    {root, remaining_bitstring} = consume_whitespace(bitstring) |> process_root_token
                                          
    #remaining_bitstring should be empty due to being in the root context otherwise this is invalid json
    unless "" === consume_whitespace(remaining_bitstring) do 
      raise UnexpectedTokenError, token: remaining_bitstring
    end

    root
  end

   defp process_root_token(<< ?{ , tail :: binary >>) do
    accept_object(tail)    
  end

  defp process_root_token(<< ?[ , tail :: binary >>) do
    accept_list(tail)
  end

  defp process_root_token(token) when is_bitstring(token) do
    raise UnexpectedTokenError, token: token
  end

  defp accept_object(bitstring) when is_bitstring(bitstring) do 
    raise "not implemented"
  end
  
  defp accept_list(bitstring) when is_bitstring(bitstring) do 
    raise "not implemented"
  end

  defp consume_whitespace(<< token :: utf8, tail :: binary>>) when token in [?\t, ?\r, ?\n, @ascii_space] do
    consume_whitespace(tail)
  end

  defp consume_whitespace(bitstring) when is_bitstring(bitstring) do
    bitstring
  end

  defp process_string_token(<< ?" , tail :: binary >>) do
    accept_string(tail, "")
  end

  defp process_string_token(<< token :: utf8, _ >>) do
    raise UnexpectedTokenError, token: token
  end

  #Stop condition for proper end of string
  defp accept_string(?", accumulator) do
    accumulator
  end
  
  defp accept_string(<<>>, _) do
    raise UnexpectedEndOfBufferError
  end

end

