require File.dirname(__FILE__) + '/spec_helper'

class FakeActionControllerBase
  attr_reader :action_name, :response
  def fake_process action_name
    @action_name = action_name
    @response = Struct.new(:template).new(Object.new)
    render_for_file :some, :args
  end
  def render_for_file *args
  end
end

class FakeController < FakeActionControllerBase
  include ActionHelper
end

module FakeHelpedActionHelper end

describe ActionHelper do
  it "has template extend helper when helper module exists" do
    controller = FakeController.new
    controller.fake_process 'helped_action'
    controller.response.template.should be_is_a(FakeHelpedActionHelper)
  end
  
  it "doesn't blow up when helper module doesn't exist" do
    controller = FakeController.new
    controller.fake_process 'non_helped_action'
    controller.response.template.should_not be_is_a(FakeHelpedActionHelper)
  end
end