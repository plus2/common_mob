require 'file_target'

class FormattedFile < FileTarget

  default_action
  def create
    args.delete('src')
    args.string = formatted_data

    super
  end


  protected
  def validate!
    unless action?(:delete, :modify)
      unless args.data?
        problem!("please specify :data")
      end
    end
  end


  # ensure AngryHashes become normal hashes.
  def data
    data = args.data
    if AngryHash === data
      data.to_normal_hash
    else
      data
    end
  end
  
end


require 'yaml'
class YamlFile < FormattedFile
  protected
  def formatted_data
    data.to_yaml
  end
end
