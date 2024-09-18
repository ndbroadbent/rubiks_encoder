#!/usr/bin/env ruby
require 'bundler/setup'
require 'kociemba'

input = ARGV[0]
if input.nil?
  puts 'No input text provided!'
  exit 1
end

input = input.upcase
puts "Input text: '#{input}'"

ALLOWED_CHARS_REGEX = /[A-Z0-9 ]/

if input.match(ALLOWED_CHARS_REGEX)
  puts 'Text is valid!'
else
  puts 'Text is invalid!'
  exit 1
end

# generic_to_color = {
#   'U' => 'B', # Up => Blue
#   'R' => 'O', # Right => Orange
#   'F' => 'Y', # Front => Yellow
#   'D' => 'G', # Down => Green
#   'L' => 'R', # Left => Red
#   'B' => 'W'  # Back => White
# }

# DEFAULT_CUBE = 'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB'

# color_cube = 'BBBGBBBBBOOOOOOOROYYYYYYYYYGGGGGBGGGRRRRRRRORWWWWWWWWW'

# color_cube = 'BGBBBBBBBOOOOOROOYYYYYYYYYGGGGGGGBGRRRRRORRRRWWWWWWWWW'

# cube = color_cube
# generic_to_color.each do |generic, color|
#   cube.gsub!(color, generic)
# end

# solver.solve(cube)

# Encode text to binary 1s and 0s
def encode_ints(string)
  string.chars.map do |char|
    # Space = 0
    # A = 1, B = 2, C = 3, ..., Z = 26
    # 0 = 27, 1 = 28, 2 = 29, ..., 9 = 36
    if char == ' '
      0
    elsif char.match?(/[A-Z]/)
      char.ord - 64
    else
      char.to_i + 26
    end
  end
end

# Return a string of five 1s and 0s to encode each integer
def encode_binary(ints)
  ints.map do |int|
    int.to_s(2).rjust(5, '0')
  end
end

int_encoded = encode_ints(input)
puts "ints: #{int_encoded}"
binary_encoded = encode_binary(int_encoded)
puts "binary_encoded: '#{binary_encoded.join(' | ')}'"

binary_string = binary_encoded.join
# binary_encoded = encode(input)
# puts "Encoded text: '#{binary_encoded}'"

# Input text: ' ASDFZ 123789'
# Text is valid!
# ints: [0, 1, 19, 4, 6, 26, 0, 27, 28, 29, 33, 34, 35]
# binary_encoded: '00000 | 00001 | 10011 | 00100 | 00110 | 11010 | 00000 | 11011 | 11100 | 11101 | 100001 | 100010 | 100011'

# solver.solve('UUUDUUUUURRRRRRRLRFFFFFFFFFDDDDDUDDDLLLLLLLRLBBBBBBBBB')

# now encode each bit as a corner/edge X orientation

# - Pick a location for each corner, and each corner can have up to 3 orientations.
# - Pick a location for each edge, and each edge can have up to 2 orientations.
# - The default cube represents a string of spaces: "                 "

# There are ways to arrange the corner cubies. Seven can be oriented independently,
# and the orientation of the eighth depends on the preceding seven
# Eleven edges can be flipped independently, with the flip of the twelfth depending on the preceding ones

# The orientation of each corner is calculated by looking at the facelets (the colors on the corner piece) and determining how much the cubie is twisted relative to its solved state.

# Identify the twist of each corner relative to its solved position (0, 1, or 2).
# Add up these values for the first seven corners.
# The sum modulo 3 (i.e., the remainder when divided by 3) of these seven values will tell you the necessary orientation for the eighth corner. This ensures that the total sum of all eight corners is divisible by 3, enforcing the corner orientation parity.

CORNERS = %w[
  FUL FUR FDR FDL BUL BUR BDR BDL
]
EDGES = %w[
  FU FR FD FL UL UR DL DR BU BR BD BL
]

# Bits stored in a single corner twist = 1.5
# 00: 0, 01: 1, 10: 2, 11: ???
# Total bits that can be stored in 7 corner twists: 10.5

def encode_cube(binary_string)
  # Flip edges first, then corners

  remaining_binary = binary_string

  stage = 0
  # 0: corner twists
  # 1: corner locations
  # 2: edge flips
  # 3: edge locations
  corner_twists = []
  corner_locations = []
  # bits = binary_string.chars



  # while bits.any?
  #   case stage
  #   when 0 # corner twists
      corner_twists = []
      bits = binary_string.chars
      corner_twist_bits = bits.shift(11)
      corner_twist_value = corner_twist_bits.reverse.join.to_i(2)

      7.times do
        corner_twist = corner_twist_value % 3
        corner_twists << corner_twist
        corner_twist_value /= 3
      end

      twist_sum = corner_twists.sum % 3
      parity_twist = (3 - twist_sum) % 3
      corner_twists << parity_twist

      stage += 1
    # when 1 # corner locations

    # end
  end
end

cube = encode_cube(binary_encoded.join)

puts cube
