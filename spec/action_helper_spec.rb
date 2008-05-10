require File.dirname(__FILE__) + '/spec_helper'

class FakeActionControllerBase
  attr_reader :action_name, :response
  def fake_process action_name
    @action_name = action_name
    @response = Struct.new(:template).new(Object.new)
    send action_name
    render_for_file :some, :args
  end
  def render_for_file *args
  end
end

class FakeController < FakeActionControllerBase
  include ActionHelper
  def action_helped_by_naming_convention; end
  def non_helped_action; end
end

module FakeActionHelpedByNamingConventionHelper end

module OtherHelper end

describe ActionHelper do
  before :each do
    @controller = FakeController.new
  end
  
  it "has template extend helper with matching name when that module exists" do
    do_action 'action_helped_by_naming_convention'
    response.template.should be_a(FakeActionHelpedByNamingConventionHelper)
  end
  
  it "doesn't mix in the helper when the names don't match" do
    do_action 'non_helped_action'
    response.template.should_not be_a(FakeActionHelpedByNamingConventionHelper)
  end
  
  def do_action action
    @controller.fake_process action
  end
  
  def response
    @controller.response
  end
  
  def be_a modul
    be_is_a modul
  end
end
