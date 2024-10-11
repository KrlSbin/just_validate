# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe JustValidate do
  before do
    chief_class = Class.new
    stub_const('Chief', chief_class)

    manager_class = Class.new
    stub_const('Manager', manager_class)

    employee_class = Class.new do
      include JustValidate

      attr_reader :name, :nick, :supervisor

      def initialize(name:, nick:, supervisor:)
        @name = name
        @nick = nick
        @supervisor = supervisor
      end

      validate :name, presence: true
      validate :nick, format: /\A[a-z]{0,5}\z/
      validate :supervisor, type: Manager
    end
    stub_const('Employee', employee_class)
  end

  describe '#validate!' do
    subject do
      employee.validate!
    end

    let!(:employee) do
      Employee.new(name: name,
                   nick: nick,
                   supervisor: supervisor)
    end

    let(:name) { 'John' }
    let(:nick) { 'nick' }
    let(:supervisor) { Manager.new }

    context 'valid object' do
      it 'should not raise error' do
        expect { subject }.not_to raise_error
      end

      it 'should return nil' do
        expect(subject).to eq nil
      end
    end

    context 'object with invalid name' do
      let(:name) { nil }

      it 'should raise error' do
        expect { subject }.to raise_error ":name for #{employee} should be present"
      end
    end

    context 'object with invalid nick' do
      let(:nick) { 'NICK' }

      it 'should raise error' do
        expect { subject }.to raise_error ":nick for #{employee} should match the format: /\\A[a-z]{0,5}\\z/"
      end
    end

    context 'object with invalid type' do
      let(:supervisor) { Chief.new }

      it 'should raise error' do
        expect { subject }.to raise_error ":supervisor for #{employee} should be kind of Manager"
      end
    end
  end

  describe '#valid?' do
    subject do
      employee.valid?
    end

    let!(:employee) do
      Employee.new(name: name,
                   nick: nick,
                   supervisor: supervisor)
    end

    let(:name) { 'John' }
    let(:nick) { 'nick' }
    let(:supervisor) { Manager.new }

    shared_examples :return_false do
      it('should return false') { expect(subject).to eq false }
    end

    context 'valid object' do
      it 'should return true' do
        expect(subject).to eq true
      end
    end

    context 'object with invalid name' do
      let(:name) { nil }

      it_behaves_like :return_false

      it 'object should contain errors' do
        subject
        expect(employee.errors).to eq [':name is empty or nil']
      end
    end

    context 'object with invalid nick' do
      let(:nick) { 'NICK' }

      it_behaves_like :return_false

      it 'object should contain errors' do
        subject
        expect(employee.errors).to eq [':nick does not match to (?-mix:\\A[a-z]{0,5}\\z)']
      end
    end

    context 'object with invalid type' do
      let(:supervisor) { Chief.new }

      it_behaves_like :return_false

      it 'object should contain errors' do
        subject
        expect(employee.errors).to eq [':supervisor is not a kind of Manager']
      end
    end

    context 'object with invalid name, nick and type' do
      let(:name) { '' }
      let(:nick) { 'NICK' }
      let(:supervisor) { Chief.new }

      it_behaves_like :return_false

      it 'object should contain errors' do
        subject
        expect(employee.errors.sort).to eq [
          ':name is empty or nil',
          ':nick does not match to (?-mix:\\A[a-z]{0,5}\\z)',
          ':supervisor is not a kind of Manager'
        ].sort
      end

      it 'object should not contain error duplicates after call valid? twice' do
        subject
        subject
        expect(employee.errors.sort).to eq [
          ':name is empty or nil',
          ':nick does not match to (?-mix:\\A[a-z]{0,5}\\z)',
          ':supervisor is not a kind of Manager'
        ].sort
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
