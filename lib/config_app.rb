require 'yaml'
Shoes.app(:title => "Opensprints Configuration") do
  if File.exists?('conf.yml')
    @prefs = YAML::load_file('conf.yml')
  else
    @prefs = YAML::load_file('conf-sample.yml')
  end
  stack do
    flow do
      para 'title (e.g. RockySprints):'
      edit_line(@prefs['title']) do |edit|
        @prefs['title'] = edit.text
      end
    end

    flow do
      para 'Race distance (METERS):'
      edit_line(@prefs['race_distance']) do |edit|
        @prefs['race_distance'] = edit.text.to_f
      end
      para '(METERS)'
    end

    flow do
      para 'Roller circumference:'
      edit_line(@prefs['roller_circumference']) do |edit|
        @prefs['roller_circumference'] = edit.text.to_f
      end
      para '(METERS)'
    end

    flow do
      para "Display speed in:"
      stack do
        metric = nil; standard = nil;
        flow do
          standard = radio(:units){ @prefs['units'] = 'standard'}
          para 'standard'
        end
        flow do
          metric = radio(:units){ @prefs['units'] = 'metric'}
          para 'metric'
        end
        if @prefs['units'] == 'metric'
          metric.checked = true
        else
          standard.checked = true
        end
      end
    end

    flow do
      para 'Track Skin:'
      sensors = Dir.glob('lib/race_windows/*.rb').map do |s|
        s.gsub(/lib\/race_windows\/(.*)\.rb/, '\1')
      end
      list_box(:items => sensors,
        :choose => @prefs['track']) do |changed|
          @prefs['track'] = changed.text

      end
    end
    flow do
      para 'Background (color or image):'
      color_edit = edit_line(@prefs['background']) do |edit|
        @prefs['background'] = edit.text
      end
      button "pick color" do
        color_edit.text = ask_color('pick...')
        @prefs['background'] = color_edit.text
      end
      button "pick file" do
        color_edit.text = ask_open_file
        @prefs['background'] = color_edit.text
        @prefs['bikes'][i] = color_edit.text
      end
    end
    flow do
      para 'Sensor type:'
      sensors = Dir.glob('lib/sensors/*_sensor.rb').map do |s|
        s.gsub(/lib\/sensors\/(.*)_sensor\.rb/, '\1')
      end
      list_box(:items => sensors,
        :choose => @prefs['sensor']['type']) do |changed|
          @prefs['sensor']['type'] = changed.text

      end
    end
    flow do
      para 'Sensor location:'
      edit_line(@prefs['sensor']['device']) do |edit|
        @prefs['sensor']['device'] = edit.text
      end
    end

    para "e.g. Mac OS X: /dev/tty.usbmodem0000103D1"
    para "e.g. Linux: /dev/ttyUSB0"
    para "e.g. Windows: com6"

    para 'Bikes:'
    @prefs['bikes']||=[]
    @r = 4.times do |i|
      flow do
        para "Bike #{i+1} Color:"
        color_edit = edit_line(@prefs['bikes'][i]) do |edit|
          @prefs['bikes'][i] = edit.text
        end
        button "pick color" do
          color_edit.text = ask_color('pick...')
          @prefs['bikes'][i] = color_edit.text
        end
        box = check { |change|
          if change.checked?
            color_edit.state = nil
          else
            color_edit.state = "disabled"
            @prefs['bikes'][i] = nil
          end
        }
        if @prefs['bikes'][i] && color_edit.text != ""
          box.checked = true
          color_edit.state = nil
        else
          color_edit.state = "disabled"
        end
        para "active?"
      end
    end


  end


  button "Save!" do
    @prefs['bikes'].compact!
    File.open('conf.yml', 'w+') do |f|
      f << @prefs.to_yaml
    end
    load "lib/setup.rb"
    alert('Preferences saved!')
    close
  end
end
