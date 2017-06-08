require File.expand_path '../spec_helper', File.dirname(__FILE__)

describe Kalman do

  describe 'predict' do

    let(:kalman) {Kalman.new}
    let(:xht1) {Numo::DFloat.new(2,1).fill 0}
    let(:ut0) {Numo::DFloat.new(2,1).fill 0}
    let(:xht0) {Numo::DFloat.new(2,1).fill 0}
    let(:ft0) {Numo::DFloat.new(2,2).fill 0}
    let(:pt1) {Numo::DFloat.new(2,2).fill 0}
    let(:pt0) {Numo::DFloat.new(2,2).fill 0}
    let(:gt0) {Numo::DFloat.new(2,2).fill 0}
    let(:qt0) {Numo::DFloat.new(2,2).fill 0}

    before do
      kalman.xht1 = xht1
      kalman.ft0 = ft0
      kalman.pt1 = pt1
      kalman.gt0 = gt0
      kalman.qt0 = qt0
    end

    it 'should calc correctly' do
      ft0[0,true] = [2,0]
      ft0[1,true] = [0,2]

      xht1[0,0] = 1
      xht1[1,0] = 2

      ut0[0,0] = 1
      ut0[1,0] = 1

      xht0[0,0] = 3
      xht0[1,0] = 5

      pt1[0,true] = [1,0]
      pt1[1,true] = [0,1]

      gt0[0,true] = [1,0]
      gt0[1,true] = [2,1]

      qt0[0,true] = [1,1]
      qt0[1,true] = [1,1]

      #10 11 11
      #21 11 33
      #
      #11 12 13
      #33 01 39

      pt0[0,true] = [5,3]
      pt0[1,true] = [3,13]
      expect(kalman.predict(ut0)).to eq [xht0, pt0]
    end
  end

  describe 'kt0' do

    let(:kalman) {Kalman.new}
    let(:pt0) {Numo::DFloat.new(2,2).fill 0}
    let(:ht0) {Numo::DFloat.new(2,2).fill 0}
    let(:st0) {Numo::DFloat.new(2,2).fill 0}
    let(:kt0) {Numo::DFloat.new(2,2).fill 0}

    before do
      kalman.instance_variable_set("@pt0", pt0)
      kalman.ht0 = ht0
      allow(kalman).to receive(:st0).and_return st0
    end

    it 'should calc correctly' do
      pt0[0,true] = [1,2]
      pt0[1,true] = [0,1]

      ht0[0,true] = [1,0]
      ht0[1,true] = [0,2]

      st0[0,true] = [2,3]
      st0[1,true] = [1,2]

      #12 10 14
      #01 02 02
      #
      #14  2-3 -25
      #02 -1 2 -24

      kt0[0,true] = [-2,5]
      kt0[1,true] = [-2,4]

      expect(kalman.kt0).to eq kt0
    end
  end
end
