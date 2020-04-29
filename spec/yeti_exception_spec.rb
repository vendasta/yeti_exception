require 'spec_helper'
require 'yeti_exception'

describe YetiException do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end
