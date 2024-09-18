module RubiksEncoder
  class Encoder
    ALLOWED_CHARS_REGEX = /[A-Z .!,?:]/
    # ALLOWED_CHARS_REGEX = /[A-Z0-9 ]/
    # ALLOWED_CHARS = ('A'..'Z').to_a + ('0'..'9').to_a + [' ']

    MAX_CHARS = 10
    BITS_PER_CHAR = 5
    MAX_BITS = MAX_CHARS * BITS_PER_CHAR

    # 8 corners
    CORNERS = %w[
      FUL FUR FDR FDL BUL BUR BDR BDL
    ]
    # 12 edges
    EDGES = %w[
      FU FR FD FL UL UR DL DR BU BR BD BL
    ]

    # 0: corner twists
    # 1: corner locations
    # 2: edge flips
    # 3: edge locations

    attr_accessor :message, :remaining_binary, :encoded_data

    def initialize(message)
      raise ArgumentError, 'message must be a string' unless message.is_a?(String)
      raise ArgumentError, 'message cannot be blank' if message == ''
      raise ArgumentError, 'message must be 10 characters or less' if message.length > MAX_CHARS

      @remaining_binary = self.class.encode_ints_to_binary_string(self.class.encode_ints(message))
      @encoded_data = {}
    end

    # Encode ASCII text to integer representation
    def self.encode_ints(string)
      string.chars.map do |char|
        # Space = 0
        # A = 1, B = 2, C = 3, ..., Z = 26
        # . = 27, ! = 28, , = 29, ? = 30, : = 31
        # ### 0 = 27, 1 = 28, 2 = 29, ..., 9 = 36
        case char
        when ' ' then 0
        when /[A-Z]/ then char.ord - 64
        when '.' then 27
        when '!' then 28
        when ',' then 29
        when '?' then 30
        when ':' then 31
        else
          raise ArgumentError, 'Invalid character in message!'
          # else
          #   char.to_i + 27
        end
      end
    end

    # Returns a string of five 1s and 0s to encode each integer
    def self.encode_ints_to_binary_string(ints)
      ints.map do |int|
        int.to_s(2).rjust(5, '0')
      end.join.ljust(MAX_BITS, '0')
    end

    def encode!
      corner_twists, @remaining_binary = encode_corner_twists(@remaining_binary)
      @encoded_data[:corner_twists] = corner_twists

      edge_flips, @remaining_binary = encode_edge_flips(@remaining_binary)
      @encoded_data[:edge_flips] = edge_flips

      corner_locations, @remaining_binary = encode_corner_locations(@remaining_binary)
      @encoded_data[:corner_locations] = corner_twists
    end

    # Corner twists can have up to 3 possible values (0 deg, 120 deg, 240 deg)
    # There are 8 corners, including 1 parity corner.
    # We can fit 11 bits into 7 ternary digits
    # - The total number of possible 11-bit binary numbers is 2^11 = 2048
    # - The total number of possible 7-digit ternary numbers is 3^7 = 2187
    def encode_corner_twists(binary_string)
      raise ArgumentError, 'binary_string must be a string' unless binary_string.is_a?(String)

      corner_twist_bits = binary_string[0..10]
      remaining_binary_data = binary_string[11..] || ''

      binary_number = corner_twist_bits.to_i(2)
      ternary_str = binary_number.to_s(3).rjust(7, '0')

      corner_twists = ternary_str.chars.map(&:to_i)

      twist_sum = corner_twists.sum % 3
      parity_twist = (3 - twist_sum) % 3
      corner_twists << parity_twist

      [corner_twists, remaining_binary_data]
    end

    def decode_corner_twists(corner_twists)
      raise ArgumentError, 'corner_twists must be an array' unless corner_twists.is_a?(Array)
      raise ArgumentError, 'corner_twists must have 8 elements' unless corner_twists.length == 8

      parity_twist = corner_twists.pop
      twist_sum = corner_twists.sum % 3
      expected_parity_twist = (3 - twist_sum) % 3
      raise ArgumentError, 'Invalid parity twist!' if parity_twist != expected_parity_twist

      binary_number = corner_twists.join.to_i(3)
      binary_number.to_s(2).rjust(11, '0')
    end

    # Edge flips can only have up to 2 possible values (0, 1)
    # There are 12 edges, including 1 parity edge.
    # So we can also fit 11 bits into the 12 edge flips.
    def encode_edge_flips(binary_string)
      raise ArgumentError, 'binary_string must be a string' unless binary_string.is_a?(String)

      edge_flip_bits = binary_string[0..10]
      remaining_binary_data = binary_string[11..-1] || ''

      edge_flips = edge_flip_bits.chars.map(&:to_i)

      [edge_flips, remaining_binary_data]
    end

    # 8 possible corner locations (permutations)
    def encode_corner_locations
      
    end
  end
end
