require 'spec_helper'
describe 'tortank' do
  context 'with default values for all parameters' do
    it { should contain_class('tortank') }
  end
end
