defmodule IdWerk.OpenSSL do
  @doc """
  Loads the key into Erlang's crypto record from pem in base64
  This module supports:

  * RSA
  """
  @spec from_pem(String.t()) :: {:ok, :public_key.pem_entry()} | :error
  def from_pem(pem) do
    case :public_key.pem_decode(pem) do
      [] -> :error
      [pem_entry] -> {:ok, :public_key.pem_entry_decode(pem_entry)}
    end
  end

  @doc """
  Generates public key based on the provided private key
  """
  @spec public_key(:public_key.pem_entry()) :: :public_key.pem_entry()
  def public_key(pem_entry) do
    pem_entry
    |> elem(0)
    |> public_key_by_alg(pem_entry)
  end

  @doc """
  Converts an Erlang public key record to pem in binary value.
  """
  @spec public_key(:public_key.pem_entry()) :: binary
  def public_key_to_pem(pem_entry) do
    :SubjectPublicKeyInfo
    |> :public_key.pem_entry_encode(pem_entry)
    |> elem(1)
  end

  def public_key_fingerprint(pem_entry) do
    key_der =
      pem_entry
      |> public_key
      |> public_key_to_pem

    payload =
      :sha256
      |> :crypto.hash(key_der)
      |> :binary.bin_to_list()
      |> Enum.take(30)
      |> :binary.list_to_bin()
      |> Base.encode32()

    list = for <<x::binary-4 <- payload>>, do: x
    Enum.join(list, ":")
  end

  defp public_key_by_alg(:RSAPrivateKey, pem_entry) do
    modulus = elem(pem_entry, 2)
    publicExponent = elem(pem_entry, 3)
    {:RSAPublicKey, modulus, publicExponent}
  end

  defp public_key_by_alg(:ECPrivateKey, pem_entry) do
    named_curve = elem(pem_entry, 3)
    public_key = elem(pem_entry, 4)

    {{:ECPoint, public_key}, named_curve}
  end
end
