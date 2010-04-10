module CommonMob
  module PatchHelper
    def patch_marker_re(comment,key,switch)
      %[
        #{Regexp.escape(comment)}
        \\s+
        angry-mob
        \\s+
        #{Regexp.escape(key)}
        \\s+
        #{Regexp.escape(switch)}
        $
      ]
    end

    def patch_file(to_patch)
      comment = args.comment || '#'
      key = args.key

      log "what the very hell?"
      if args.src?
        src = args.src.pathname.read
      elsif args.string?
        src = args.string
      end

      content = "#{comment} angry-mob #{key} start\n#{src}" \
        "\n#{comment} angry-mob #{key} end"

      pattern = %r[
        #{patch_marker_re(comment,key,'start')}
        .*
        #{patch_marker_re(comment,key,'end')}
      ]mx

      to_patch = to_patch.read

      if to_patch[pattern]
        to_patch.gsub(pattern,content)
      else
        to_patch + "\n" + content
      end
    end

  end
end
