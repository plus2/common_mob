require 'common_mob/erb'
require 'mustache'

module CommonMob
  module Mustache
    def render_mustache(src,variables)
      ::Mustache.render(src.read, variables)
    end
  end

  module Template
    include CommonMob::Mustache
    include CommonMob::Erb
    
    def render_template(src,variables)
      if src.to_s[/\.mustache$/]
        render_mustache(src,variables)
      else
        render_erb(src,variables)
      end
    end
  end    
end
