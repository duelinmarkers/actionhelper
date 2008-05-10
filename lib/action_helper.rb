module ActionHelper

  def self.included klass
    klass.extend ClassMethods
  end
  
  def action_helper *args
    args.each {|helper| response.template.extend helper }
  end
  
  private

  def render_for_file *args
    extend_if_necessary
    super
  end
  
  def extend_if_necessary
    action_module = self.class.master_action_helper_for(action_name)
    unless action_module == :no_action_helper
      response.template.extend action_module
    end
  end
  
  module ClassMethods
    def master_action_helpers
      @master_action_helpers ||= {}
    end
    
    def master_action_helper_for action_name
      master_action_helpers[action_name] ||= build_master_action_helper_for action_name
    end
    
    def build_master_action_helper_for action_name
      controller_part = self.name.sub(/Controller$/, '')
      action_part = action_name.camelize
      "#{controller_part}#{action_part}Helper".constantize
    rescue NameError
      :no_action_helper
    end
  end
end