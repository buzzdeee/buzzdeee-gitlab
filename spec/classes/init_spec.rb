require 'spec_helper'
describe 'gitlab' do
  context 'with default values for all parameters' do
    it { should contain_class('gitlab') }
  end
end
