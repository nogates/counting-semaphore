require 'counting-semaphore'
require 'pry-debugger'

describe CountingSemaphore::Image do
  let(:test_images_folder) { File.join(__dir__, 'test_images') }
  let(:csv_file)           { double }
  let(:tolerance)          { nil }
  let(:headers) do
    [ 'File name',
      'Total red pixels', 'Total red over blue', 'Total red over green',
      'Total blue pixels', 'Total blue over red', 'Total blue over green',
      'Total green pixels', 'Total green over red', 'Total green over blue'
    ]
  end

  def expand_image_path(image)
    File.expand_path(File.join(test_images_folder, image))
  end

  before do
    allow(CSV).to receive(:open).with('results.csv', 'w').and_yield(csv_file)
  end

  after do
    described_class.folder_to_csv(folder: test_images_folder, tolerance: tolerance)
  end

  context 'when running with default values' do
    it 'inserts in the csv file the right rows' do
      expect(csv_file).to receive(:'<<').with(headers).once
      expect(csv_file).to receive(:'<<')
        .with([ expand_image_path('overlay_channels.jpg'), 6, 4, 4, 6, 4, 4, 6, 4, 4 ]).once
      expect(csv_file).to receive(:'<<')
        .with([ expand_image_path('pure_channels.jpg'), 2, 0, 0, 2, 0, 0, 2, 0, 0 ]).once
    end
  end
end
