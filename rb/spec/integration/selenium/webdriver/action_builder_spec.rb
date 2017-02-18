# encoding: utf-8
#
# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require_relative 'spec_helper'

module Selenium
  module WebDriver
    not_compliant_on browser: [:safari, :firefox] do
      not_compliant_on browser: [:firefox, :ff_nightly], driver: :remote do
        describe ActionBuilder do
          describe 'Key actions' do
            it 'sends keys to the active element' do
              driver.navigate.to url_for('bodyTypingTest.html')
              keylogger = driver.find_element(id: 'body_result')

              driver.find_element(css: 'body').click
              driver.action.send_keys('ab').perform

              wait.until { keylogger.text.split.length == 2 }
              expect(keylogger.text.strip).to eq('keypress keypress')

              expect(driver.find_element(id: 'result').text.strip).to be_empty
            end

            it 'can send keys with shift pressed' do
              driver.navigate.to url_for('javascriptPage.html')

              event_input = driver.find_element(id: 'theworks')
              keylogger = driver.find_element(id: 'result')

              event_input.click

              driver.action.key_down(:shift).send_keys('ab').key_up(:shift).perform
              wait.until { event_input.attribute(:value).length == 2 }

              expect(event_input.attribute(:value)).to eq('AB')
              expect(keylogger.text.strip).to match(/^(focus )?keydown keydown keypress keyup keydown keypress keyup keyup$/)
            end

            it 'can press and release modifier keys' do
              driver.navigate.to url_for('javascriptPage.html')

              event_input = driver.find_element(id: 'theworks')
              keylogger = driver.find_element(id: 'result')

              event_input.click

              driver.action.key_down(:shift).perform
              wait.until { keylogger.text.include? 'down' }
              expect(keylogger.text).to match(/keydown *$/)

              driver.action.key_up(:shift).perform
              wait.until { keylogger.text.include? 'up' }
              expect(keylogger.text).to match(/keyup *$/)
            end

            # These requires pointer actions to be working in Firefox first
            not_compliant_on driver: [:firefox, :ff_nightly] do
              it 'can send keys to element' do
                driver.navigate.to url_for('formPage.html')

                input = driver.find_element(css: '#working')

                driver.action.send_keys(input, 'abcd').perform
                wait.until { input.attribute(:value).length == 4 }
                expect(input.attribute(:value)).to eq('abcd')
              end

              it 'can send multiple send_keys commands' do
                driver.navigate.to url_for('formPage.html')

                input = driver.find_element(css: '#working')

                driver.action.send_keys(input, 'abcd', 'dcba').perform
                wait.until { input.attribute(:value).length == 8 }
                expect(input.attribute(:value)).to eq('abcddcba')
              end

              # Certain non-ascii keys are not working in Firefox yet (known but un-filed bug)
              it 'can send non-ascii keys' do
                driver.navigate.to url_for('formPage.html')

                input = driver.find_element(css: '#working')

                driver.action.send_keys(input, 'abcd', :left, 'a').perform
                wait.until { input.attribute(:value).length == 5 }
                expect(input.attribute(:value)).to eq('abcad')
              end
            end

            compliant_on driver: :firefox do
              it 'can release pressed keys via release action' do
                driver.navigate.to url_for('javascriptPage.html')

                event_input = driver.find_element(id: 'theworks')
                keylogger = driver.find_element(id: 'result')

                event_input.click

                driver.action.key_down(:shift).perform
                wait.until { keylogger.text.include? 'down' }
                expect(keylogger.text).to match(/keydown *$/)

                driver.action.release_actions
                wait.until { keylogger.text.include? 'up' }
                expect(keylogger.text).to match(/keyup *$/)
              end
            end
          end # Key actions

          not_compliant_on browser: [:safari, :firefox, :ff_nightly] do
            describe 'Pointer actions' do
              it 'clicks an element' do
                driver.navigate.to url_for('formPage.html')
                original_title = driver.title
                driver.action.click(driver.find_element(id: 'imageButton')).perform
                Wait.new.until { driver.title != original_title }
                expect(driver.title).to eq 'We Arrive Here'
              end

              it 'can drag and drop' do
                driver.navigate.to url_for('droppableItems.html')

                draggable = long_wait.until do
                  driver.find_element(id: 'draggable')
                end

                droppable = driver.find_element(id: 'droppable')

                driver.action.drag_and_drop(draggable, droppable).perform

                text = droppable.find_element(tag_name: 'p').text
                expect(text).to eq('Dropped!')
              end

              it 'double clicks an element' do
                driver.navigate.to url_for('javascriptPage.html')
                element = driver.find_element(id: 'doubleClickField')

                driver.action.double_click(element).perform
                expect(element.attribute(:value)).to eq('DoubleClicked')
              end
              not_compliant_on browser: :phantomjs do
                it 'context clicks an element' do
                  driver.navigate.to url_for('javascriptPage.html')
                  element = driver.find_element(id: 'doubleClickField')

                  driver.action.context_click(element).perform
                  expect(element.attribute(:value)).to eq('ContextClicked')
                end
              end

              compliant_on driver: :firefox do
                it 'can release pressed buttons via release action' do
                  driver.navigate.to url_for('javascriptPage.html')

                  event_input = driver.find_element(id: 'clickField')

                  driver.action.click_and_hold(event_input).perform
                  expect(event_input.attribute(:value)).to eq('Hello')

                  driver.action.release_actions
                  expect(event_input.attribute(:value)).to eq('Clicked')
                end
              end
            end # Pointer actions
          end # Guard
        end # ActionBuilder
      end # Guard
    end # Guard
  end # WebDriver
end # Selenium