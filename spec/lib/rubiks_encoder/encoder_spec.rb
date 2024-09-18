# frozen_string_literal: true

require 'spec_helper'
require 'rubiks_encoder/encoder'

RSpec.describe RubiksEncoder::Encoder do
  it 'returns the correct values for #encode_ints' do
    expect(RubiksEncoder::Encoder.encode_ints('ABC XYZ')).to eq([1, 2, 3, 0, 24, 25, 26])
    expect(RubiksEncoder::Encoder.encode_ints('.!,?:')).to eq([27, 28, 29, 30, 31])
    expect { RubiksEncoder::Encoder.encode_ints('%') }.to raise_error(ArgumentError, 'Invalid character in message!')
  end

  it 'returns the correct values for #encode_ints_to_binary_string' do
    expect(
      RubiksEncoder::Encoder.encode_ints_to_binary_string(
        [0, 1, 2, 3, 0, 24, 25, 26]
      ).scan(/.{5}/)
    ).to eq %w[00000 00001 00010 00011 00000 11000 11001 11010 00000 00000]

    punctuation_binary = RubiksEncoder::Encoder.encode_ints_to_binary_string(
      [29, 30, 31]
    ).scan(/.{5}/)
    expect(punctuation_binary.count).to eq 10
    expect(punctuation_binary.first(3)).to eq %w[11101 11110 11111]
    expect(punctuation_binary.last(7).uniq).to eq %w[00000]
  end

  it 'returns the correct values for #encode_corner_twists' do
    encoder = RubiksEncoder::Encoder.new(' ')

    expect(encoder.encode_corner_twists('00000000000')).to eq(
      [[0, 0, 0, 0, 0, 0, 0, 0], '']
    )
    expect(encoder.encode_corner_twists('00000000001')).to eq(
      [[0, 0, 0, 0, 0, 0, 1, 2], '']
    )
    expect(encoder.encode_corner_twists('10000000000')).to eq(
      [[1, 1, 0, 1, 2, 2, 1, 1], '']
    )
    expect(encoder.encode_corner_twists('10000000000')).to eq(
      [[1, 1, 0, 1, 2, 2, 1, 1], '']
    )
    expect(encoder.encode_corner_twists('11111111111000')).to eq(
      [[2, 2, 1, 0, 2, 1, 1, 0], '000']
    )
    expect(encoder.encode_corner_twists('000000000001')).to eq(
      [[0, 0, 0, 0, 0, 0, 0, 0], '1']
    )
  end

  it 'returns the correct values for #decode_corner_twists' do
    encoder = RubiksEncoder::Encoder.new(' ')

    expect(encoder.decode_corner_twists([0, 0, 0, 0, 0, 0, 0, 0])).to eq(
      '00000000000'
    )
    expect(encoder.decode_corner_twists([0, 0, 0, 0, 0, 0, 1, 2])).to eq(
      '00000000001'
    )
    expect(encoder.decode_corner_twists([0, 0, 0, 0, 0, 0, 2, 1])).to eq(
      '00000000010'
    )
    expect { encoder.decode_corner_twists([0, 0, 0, 0, 0, 0, 0, 1]) }.to raise_error(
      ArgumentError, 'Invalid parity twist!'
    )
  end

  it 'returns the correct values for #encode_edge_flips' do
    encoder = RubiksEncoder::Encoder.new(' ')

    expect(encoder.encode_edge_flips('00000000000')).to eq(
      [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], '']
    )
    expect(encoder.encode_edge_flips('00000000001')).to eq(
      [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], '']
    )
    expect(encoder.encode_edge_flips('10000000000')).to eq(
      [[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], '']
    )
    expect(encoder.encode_edge_flips('11111111111000')).to eq(
      [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], '000']
    )
    expect(encoder.encode_edge_flips('000000000001')).to eq(
      [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], '1']
    )
  end
end
