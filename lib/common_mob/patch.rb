module CommonMob
  module PatchHelper
    def patch_marker_re(comment,key,switch)
      %[
        #{Regexp.escape(comment.to_s)}
        \\s+
        angry-mob
        \\s+
        #{Regexp.escape(key.to_s)}
        \\s+
        #{Regexp.escape(switch.to_s)}
        $
      ]
    end

    def patch_string(to_patch, src, options={})
      comment = options[:comment] || '#'
      key     = options[:key]

      content = "#{comment} angry-mob #{key} start\n#{src}" \
        "\n#{comment} angry-mob #{key} end"

      pattern = %r[
        #{patch_marker_re(comment,key,'start')}
        .*
        #{patch_marker_re(comment,key,'end')}
      ]mx

      if to_patch[pattern]
        to_patch.gsub(pattern,content)
      else
        to_patch + "\n" + content
      end
    end

    def patch_file(to_patch)
      log "what the very hell?"
      if args.src?
        src = args.src.pathname.read
      elsif args.string?
        src = args.string
      end

      patch_string(to_patch.read, src, {
        :comment => args.comment,
        :key => args.key,
      })
    end

  end
end
