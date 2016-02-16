require 'vagrant'

# Define the plugin.
class RebootPlugin < Vagrant.plugin('2')
    name 'Reboot Plugin'

    # This plugin provides a provisioner called reboot.
    provisioner 'reboot' do

        # Create a provisioner.
        class RebootProvisioner < Vagrant.plugin('2', :provisioner)
            # Initialization, define internal state. Nothing needed.
            def initialize(machine, config)
                super(machine, config)
            end

            # Configuration changes to be done. Nothing needed here either.
            def configure(root_config)
                super(root_config)
            end

            # Run the provisioning.
            def provision
                # Restart now
                @machine.ui.info("Restarting the machine")
                @machine.communicate.sudo('shutdown -r now') do |type, data|
                    if type == :stderr
                        @machine.ui.error(data);
                    end
                end
                begin
                    sleep 5
                end until @machine.communicate.ready?
                
                # Update vbguest
                @machine.ui.info("Updating vb-guests")
                @machine.communicate.sudo('/etc/init.d/vboxadd setup') do |type, data|
                    if type == :stderr
                        @machine.ui.error(data);
                    end
                end

                # Do reload
                @machine.ui.info("Reloading the VM")
                options = {}
                options[:provision_ignore_sentinel] = false
                @machine.action(:reload, options)
                begin
                    sleep 5
                end until @machine.communicate.ready?
            end

            # Nothing needs to be done on cleanup.
            def cleanup
                super
            end
        end
        RebootProvisioner

    end
end
